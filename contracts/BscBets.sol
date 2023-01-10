// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./IERC20.sol";
import "./SafeMath.sol";


contract BscBets {
    // Global Random Seed
    string globalSeed = "genesis";
    
    // Reward Pool Balance
    uint public rewardPoolBalance;
    
    // BscBets Revenue Balance
    uint public revenueBalance;

    // BET Token Address
    IERC20 BET = IERC20(0x44FF97802090808199840E868F280aeB54FBbDf0);

    function updateGlobalSeed(string memory _seed) public {
        globalSeed = _seed;
    }

    function decimalWrapper(uint _number) public pure returns (uint multiplier){
        return _number * 10**14;
    }

    function multiplierProbabilityLogic(uint _multiplier) public pure returns (uint probability){
        uint multiplier = _multiplier;
        /*
        Max decimal for multiplier is 14
        */
        require(1<=multiplier, "Invalid multiplier. Should be equal or bigger than 100");
        require(multiplier<=100, "Invalid multiplier. Should be equal or smaller than 100");
        /*
        Multiplier is from 1x to 100x. The probability for multiplier is as follows.

        probability = 70/multiplier
        */
        probability = decimalWrapper(70) / multiplier;
        return probability;
    }

    function getWinMultiplier() {

    }


    // function createBet(uint _betAmount, uint _multiplierLimit) public {
        
    // }

    // function withdrawReward

}