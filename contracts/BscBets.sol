// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./VRFv2Consumer.sol";

interface ChainlinkVRF {
    function requestRandomWords() external returns (uint256);
    function getRequestStatus(uint256) external returns (bool, uint256[] memory);
    function lastRequestId() external view returns (uint256);
}

contract BscBets {
    // Set Chainlink interface
    ChainlinkVRF public chainlinkVRF;

    // Admin Address
    address admin = 0xA57d9222Fbd1BDbfc03e6CEfb36365E148c93F62;

    // User Balance Map(Wei)
    mapping(address => uint) public userBalanceMapWei;
    
    // Reward Pool Balance
    uint public rewardPoolBalanceWei;
    
    // BET Token Address
    address BET = 0x47DbA3639dda3b927EA20F754fAb0973dC26cC65;

    // Probability distribution array (100~10000)
    uint [] probabilityArray;

    // Probability distribution array (VIP) (100~10000)
    uint [] vipProbabilityArray;

    // Min LP Token for VIP
    uint vipThreshold = 10000;

    // VRF Functions
    function getRandomInt() public returns(uint256){
        uint256 requestId = chainlinkVRF.requestRandomWords();
        bool fulfilled;
        uint256[] memory randomWords;
        (fulfilled, randomWords) = chainlinkVRF.getRequestStatus(requestId);
        require(fulfilled==true, "VRF not fulfilled");
        return randomWords[0];
    }

    // Onlyowner
    function updateProbabilityArray(uint[] memory _probabilityArray) public {
        require(msg.sender==admin, "Only admin can access");
        probabilityArray = _probabilityArray;
    }

    function updateVipProbabilityArray(uint[] memory _vipProbabilityArray) public {
        require(msg.sender==admin, "Only admin can access");
        vipProbabilityArray = _vipProbabilityArray;
    }

    function decimalWrapper(uint _number) public pure returns (uint number){
        return _number * 10**14;
    }

    function decimalUnWrapper(uint _number) public pure returns (uint number){
        return _number / 10**14;
    }

    function getWinMultiplier(bool _isVip) public returns (uint winMultiplier){
        uint randomInt = getRandomInt();
        if (_isVip) {
            winMultiplier = vipProbabilityArray[randomInt%probabilityArray.length];
        } else {
            winMultiplier = probabilityArray[randomInt%probabilityArray.length];
        }
        return winMultiplier;
    }


    function createBet(uint _betAmountWei, uint _multiplierLimit) public returns (bool win) {
        require(_betAmountWei>=100, "betamount too small");
        require(_multiplierLimit<=10000, "invalid multiplierLimit");
        require(_multiplierLimit>=100, "invalid multiplierLimit");
        require(ERC20(BET).transferFrom(msg.sender, address(this), _betAmountWei), "Transfer Unsuccesful");
        userBalanceMapWei[msg.sender] += _betAmountWei;

        bool isVip;
        if(userLpBalanceMap[msg.sender] >= vipThreshold) {
            isVip = true;
        } else{
            isVip = false;
        }

        uint winMultiplier = getWinMultiplier(isVip);
        
        
        if (_multiplierLimit <= winMultiplier) {
            userBalanceMapWei[msg.sender] = _betAmountWei * _multiplierLimit / 100;
            rewardPoolBalanceWei -= _betAmountWei * (_multiplierLimit-100) / 100;
            win = true;
        } else {
            userBalanceMapWei[msg.sender] = 0;
            rewardPoolBalanceWei += _betAmountWei;
            win = false;
        }
        
        return win;
    }

    function withdrawReward() public payable {
        uint currentBalance = userBalanceMapWei[msg.sender];
        require(ERC20(BET).approve(msg.sender, currentBalance));
        require(ERC20(BET).transferFrom(address(this), msg.sender, currentBalance), "Transfer Unsuccesful");
        userBalanceMapWei[msg.sender] = 0; 
    }

    function adminDepositRewardPool(uint _amount) public {
        require(msg.sender==admin, "Only admin can access");
        require(ERC20(BET).transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        rewardPoolBalanceWei += _amount;
    }

    function adminWithdrawRewardPool(uint _amount) public payable{
        require(msg.sender==admin, "Only admin can access");
        require(_amount<=rewardPoolBalanceWei, "insufficient fee");
        require(ERC20(BET).approve(msg.sender, _amount));
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        rewardPoolBalanceWei -= _amount;
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
        for (uint i=0; i<userAddressArray.length; i++) {
            address userAddress = userAddressArray[i];
            uint userLpBalance = userLpBalanceMap[userAddress];
            uint rewardAmount = rewardEmissionPerDay * userLpBalance / netLpTokenBalance ;
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
        require(ERC20(BET).approve(msg.sender, _amount));
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        rewardReserveBalance -= _amount;
    }

    function depositLpToken(uint _amount) public {
        require(BET_USDC.transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        userLpBalanceMap[msg.sender] += _amount;
    }

    function withdrawLpToken(uint _amount) public payable{
        require(BET_USDC.approve(msg.sender, _amount));
        require(BET_USDC.transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        userLpBalanceMap[msg.sender] -= _amount;
    }

    function withdrawReward(uint _amount) public {
        require(ERC20(BET).approve(msg.sender, _amount));
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        userFarmingRewardMap[msg.sender] -= _amount;
    }
}