// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract BscBets {
    // Global Random Seed
    string globalSeed = "genesis";

    // Admin Address
    address admin = 0xA57d9222Fbd1BDbfc03e6CEfb36365E148c93F62;

    // User Balance Map
    mapping(address => uint) public userBalanceMap;
    
    // Reward Pool Balance
    uint public rewardPoolBalance;
    
    // BET Token Address
    address BET = 0x7a7813265032cC4b08332CF531Fc377134e91ac8;

    // Probability distribution array (100~10000)
    uint [] probabilityArray;

    // Probability distribution array (VIP) (100~10000)
    uint [] vipProbabilityArray;

    // Min LP Token for VIP
    uint vipThreshold = 10000;

    // Onlyowner
    function updateProbabilityArray(uint[] memory _probabilityArray) private {
        require(msg.sender==admin, "Only admin can access");
        probabilityArray = _probabilityArray;
    }

    function updateVipProbabilityArray(uint[] memory _vipProbabilityArray) private {
        require(msg.sender==admin, "Only admin can access");
        vipProbabilityArray = _vipProbabilityArray;
    }

    function updateGlobalSeed(string memory _seed) public {
        require(msg.sender==admin, "Only admin can access");
        globalSeed = _seed;
    }

    function decimalWrapper(uint _number) public pure returns (uint number){
        return _number * 10**14;
    }

    function getRandomInt() public view returns (uint randomInt) {
        randomInt = uint(
            keccak256(
                abi.encodePacked(
                    block.coinbase,
                    block.difficulty,
                    block.timestamp,
                    globalSeed
                )
            )
        );
        return randomInt;
    }

    function getWinMultiplier(bool _isVip) public view returns (uint winMultiplier){
        uint randomInt = getRandomInt();
        if (_isVip) {
            winMultiplier = vipProbabilityArray[randomInt%probabilityArray.length];
        } else {
            winMultiplier = probabilityArray[randomInt%probabilityArray.length];
        }
        return winMultiplier;
    }


    function createBet(uint _betAmount, uint _multiplierLimit) public returns (bool win) {
        require(_multiplierLimit<=10000, "invalid multiplierLimit");
        require(_multiplierLimit>=100, "invalid multiplierLimit");

        require(ERC20(BET).transferFrom(msg.sender, address(this), _betAmount), "Transfer Unsuccesful");
        userBalanceMap[msg.sender] += _betAmount;

        bool isVip;
        if(userLpBalanceMap[msg.sender] >= vipThreshold) {
            isVip = true;
        } else{
            isVip = false;
        }

        uint winMultiplier = getWinMultiplier(isVip);
        
        if (_multiplierLimit <= winMultiplier) {
            userBalanceMap[msg.sender] = _betAmount*_multiplierLimit/100;
            rewardPoolBalance -= _betAmount*(_multiplierLimit-100)/100;
            win = true;
        } else {
            userBalanceMap[msg.sender] = 0;
            rewardPoolBalance += _betAmount/100;
            win = false;
        }
        return win;
    }

    function withdrawReward() public payable {
        uint currentBalance = userBalanceMap[msg.sender];
        require(ERC20(BET).transferFrom(address(this), msg.sender, currentBalance), "Transfer Unsuccesful");
        userBalanceMap[msg.sender] = 0; 
    }

    function adminDepositRewardPool(uint _amount) public {
        require(msg.sender==admin, "Only admin can access");
        require(ERC20(BET).approve(msg.sender, _amount), "Not Approved");
        require(ERC20(BET).transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        rewardPoolBalance += _amount;
    }

    function adminWithdrawRewardPool(uint _amount) public payable{
        require(msg.sender==admin, "Only admin can access");
        require(_amount<=rewardPoolBalance, "insufficient fee");
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        rewardPoolBalance -= _amount;
    }

    /*
    BET-USDC LP Token
    */
    ERC20 BET_USDC = ERC20(0x974b6a2AaBB0B0dd5223C341DD3f2F1210F4a3bF);
    mapping(address => uint) public userLpBalanceMap;
    mapping(address => uint) public userFarmingRewardMap;
    address[] public userAddressArray;
    uint rewardEmissionPerDay;
    uint netLpTokenBalance;

    uint rewardReserveBalance;
    uint lastUpdateTs;
    uint tsEpochLength = 60 * 60 * 24;

    function updateRewards() public {
        require(block.timestamp-lastUpdateTs >= tsEpochLength, "Cannot be updated now");
        require(rewardReserveBalance >= rewardEmissionPerDay, "Insufficient reserve");
        uint rewardPerLpToken = rewardEmissionPerDay/netLpTokenBalance;
        for (uint i=0; i<userAddressArray.length; i++) {
            address userAddress = userAddressArray[i];
            uint userLpBalance = userLpBalanceMap[userAddress];
            uint rewardAmount = rewardPerLpToken * userLpBalance;
            userFarmingRewardMap[userAddress] += rewardAmount;
        }
        rewardReserveBalance -= rewardEmissionPerDay;
        lastUpdateTs += tsEpochLength;
    }

    function setRewardEmissionPerDay(uint _amount) public {
        require(msg.sender==admin, "Only admin");
        require(rewardReserveBalance >= _amount, "Insufficient Balance");
        rewardEmissionPerDay = _amount;
    }

    function adminDepositRewards(uint _amount) public {
        require(ERC20(BET).transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        rewardReserveBalance += _amount;
    }

    function adminWithdrawRewards(uint _amount) public payable{
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        rewardReserveBalance -= _amount;
    }

    function depositLpToken(uint _amount) public {
        require(BET_USDC.transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        userLpBalanceMap[msg.sender] += _amount;
    }

    function withdrawLpToken(uint _amount) public payable{
        require(BET_USDC.transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        userLpBalanceMap[msg.sender] -= _amount;
    }

    function withdrawReward(uint _amount) public {
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        userFarmingRewardMap[msg.sender] -= _amount;
    }
}