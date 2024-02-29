// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IL3tTokens.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
// import "@chainlink/contracts/src/v0.8/vrf/ConfirmedOwner.sol";

contract RandomPrize is VRFConsumerBaseV2, ConfirmedOwner {
    uint gameId;
    uint playerCount;
    address GameMaster;
    uint totalTaskEntries;
    address gamingToken;
    mapping(string => uint) public taskEntries;
    mapping(string => bool) public activeTasks;
    mapping(address => Players[]) players;
    mapping(string => uint) public taskEndTime;


    struct Players {
        uint playerId;
        string codeName;
        uint entries;
    }

   
}