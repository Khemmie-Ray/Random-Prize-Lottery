// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IL3tTokens.sol";
import "./RandomWinner.sol";

contract RandomPrize {
    uint gameId;
    uint playerCount;
    address gameMaster;
    uint totalTaskEntries;
    address gamingToken;
    RandomWinner randomWinner;
    mapping(string => uint) public taskEntries;
    mapping(string => bool) public activeTasks;
    mapping(address => Players[]) players;
    mapping(string => uint) public taskEndTime;


    struct Players {
        uint playerId;
        string codeName;
        address gamePlayer;
        uint entries;
    }

   struct Tasks {
        string battle;
        string karoke;
        string poker;
        string casino;
   }

   event RegisterSuccess(address indexed player, uint playerId, string codeName);
   event GameStarted(string indexed task, uint endTime);
   event PrizeDistribution(uint totalPrize, address winner, uint entries);

   constructor(address _gamingToken) {
       gameMaster = msg.sender;
        gamingToken = _gamingToken;

        taskEntries["battle"] = 3;
        taskEntries["karaoke"] = 2;
        taskEntries["poker"] = 5;
        taskEntries["casino"] = 4;
   }

   function registerAsPlayer(string memory _codeName) external {
        require(bytes(_codeName).length > 0, "Code name can't be empty");
        require(players[msg.sender].length == 0, "Player already registered");

        uint playerId = playerCount + 1; 

        Players memory newPlayer = Players({
            playerId: playerId,
            gamePlayer: msg.sender,
            codeName: _codeName,
            entries: 0
        });

        players[msg.sender].push(newPlayer);
        emit RegisterSuccess(msg.sender, playerId, _codeName);
   }

   function getPlayersByAddress(address _player) external view returns(Players[] memory) {
        return players[_player];
   }

   function startGame(string memory _task, uint _duration) external {
        require(msg.sender == gameMaster, "Only GameMaster can start a task");
        require(bytes(_task).length > 0, "Invalid task");
        require(!activeTasks[_task], "Task already active");

        uint calcDuration = 360 * _duration;
        uint endTime = block.timestamp + calcDuration;
        activeTasks[_task] = true;
        taskEndTime[_task] = endTime;

        emit GameStarted(_task, endTime);
   }

    function joinGame(string memory _task) external {
        require(players[msg.sender].length > 0, "Player not registered");
        require(activeTasks[_task], "Task not active");
        require(bytes(_task).length > 0, "Invalid task");

        uint taskEntriesEarned = taskEntries[_task];
        players[msg.sender][0].entries += taskEntriesEarned;
        totalTaskEntries += players[msg.sender][0].entries;
    }

    function startPrizeDistribution(uint totalPrize) external {
        require(msg.sender == gameMaster, "Only GameMaster can start prize distribution");
        require(totalTaskEntries > 0, "No entries to distribute");

        for (uint i = 0; i < players[msg.sender].length; i++) {
        Players storage PY = players[msg.sender][i];
        if (PY.entries > 0) {
            uint share = (PY.entries * totalPrize) / totalTaskEntries;
            
            IL3tTokens(gamingToken).transfer(PY.gamePlayer, share);

            emit PrizeDistribution(share, msg.sender, PY.entries);
        }
    }
    }

   function getRandomWinner(string memory _task) external {
        require(msg.sender == gameMaster, "Only GameMaster can generate random winner");
        require(activeTasks[_task], "Task not active");
        require(bytes(_task).length > 0, "Invalid task");

        uint requestId = randomWinner.requestRandomWords();
        randomWinner.getRequestStatus(requestId);
    //  randomWinner.requestRandomWords();
    //  uint latestId = randomWinner.returnLatestId();
    //  randomWinner.getRequestStatus(latestId);
   }
}