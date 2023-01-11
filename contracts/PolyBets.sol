// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./VRFv2Consumer.sol";

interface ChainlinkVRF {
    function requestRandomWords() external;
    function getRequestStatus(uint256) external returns (bool, uint256[] memory);
    function lastRequestId() external view returns (uint256);
}

contract PolyBets {

    // Set contract deployer as admin
    constructor() {
        address admin = msg.sender;
    }

    // Set Chainlink interface
    ChainlinkVRF public chainlinkVRF;

    // User Bet Struct
    struct BetInfo {
        uint balance;
        uint multiplier;
        uint vrfRequestId;
    }

    /*
        basic vip level: 1, 2, 3
        temporary vip count:
            new user without referral: 5
            isReferred -> 10
            isReferrer -> 10
    */

    struct UserInfo {
        uint vipLevel; // 1, 2, 3
        uint netVolume;
        bool isTemporaryVip; // False
        uint temporaryVipCount; // 0
    }

    // User Info Map
    mapping(address => UserInfo) public userInfoMap;

    // User Bet Map
    mapping(address => BetInfo) public betInfoMap;
    
    // Reward Pool Balance
    uint public rewardPoolBalanceWei;
    
    // BET Token Address
    address BET = 0x47DbA3639dda3b927EA20F754fAb0973dC26cC65;

    // Probability distribution array (100~10000)
    uint [] vip1ProbabilityArray;

    uint [] vip2ProbabilityArray;

    uint [] vip3ProbabilityArray;

    uint [] temporaryVipProbabilityArray;
    
    // Min LP Token for VIP
    uint minVipVolume = 10000;

    // Onlyowner
    function updateVip1ProbabilityArray(uint[] memory _vip1ProbabilityArray) public {
        require(msg.sender==admin, "Only admin can access");
        vip1ProbabilityArray = _vip1ProbabilityArray;
    }

    function updateVip2ProbabilityArray(uint[] memory _vip2ProbabilityArray) public {
        require(msg.sender==admin, "Only admin can access");
        vip2ProbabilityArray = _vip2ProbabilityArray;
    }

    function updateVip3ProbabilityArray(uint[] memory _vip3ProbabilityArray) public {
        require(msg.sender==admin, "Only admin can access");
        vip3ProbabilityArray = _vip3ProbabilityArray;
    }

    function updateTemporaryVipProbabilityArray(uint[] memory _temporaryVipProbabilityArray) public {
        require(msg.sender==admin, "Only admin can access");
        temporaryVipProbabilityArray = _temporaryVipProbabilityArray;
    }

    function createAccount(address referrer) public {
        userAddressArray.push(msg.sender);
        // Check referrer
        if (userInfoMap[referrer].netVolume>=minVipVolume) {
            UserInfo memory userInfo = UserInfo(1, 0, 5);
        }
        else {
            UserInfo memory userInfo = UserInfo(1, 0, 4);
            userInfoMap[msg.sender] = userInfo;
        }
    }

    function getWinMultiplier(uint256 _randInt) public returns (uint winMultiplier){
        uint _vipLevel=userInfoMap[msg.sender].vipLevel;
        if (_vipLevel==1) {
            winMultiplier = vip1ProbabilityArray[_randInt%vip1ProbabilityArray.length];
        } else if(_vipLevel==2){
            winMultiplier = vip2ProbabilityArray[_randInt%vip2ProbabilityArray.length];
        } else if(_vipLevel==3){
            winMultiplier = vip3ProbabilityArray[_randInt%vip3ProbabilityArray.length];
        } else if(_vipLevel==4){
            winMultiplier = vip4ProbabilityArray[_randInt%vip4ProbabilityArray.length];
        } else {
            winMultiplier = vip5ProbabilityArray[_randInt%vip5ProbabilityArray.length];
        }
        return winMultiplier;
    }

    // function getWinMultiplier(bool _isVip, uint256 _randInt) public returns (uint winMultiplier){
    //     if (_isVip) {
    //         winMultiplier = vipProbabilityArray[_randInt%probabilityArray.length];
    //     } else {
    //         winMultiplier = probabilityArray[_randInt%probabilityArray.length];
    //     }
    //     return winMultiplier;
    // }

    function createBet(uint _betAmountWei, uint _multiplierLimit) public {
        require(_betAmountWei>=100, "betamount too small");
        require(_multiplierLimit<=10000, "invalid multiplierLimit");
        require(_multiplierLimit>=100, "invalid multiplierLimit");
        require(ERC20(BET).transferFrom(msg.sender, address(this), _betAmountWei), "Transfer Unsuccesful");

        // VRF
        chainlinkVRF.requestRandomWords();
        uint256 requestId = chainlinkVRF.lastRequestId();

        BetInfo storage betInfo = BetInfo(_betAmountWei, _multiplierLimit, requestId);
        betInfoMap[msg.sender] = betInfo;
    }

    function determineWin() public {
        BetInfo storage betInfo = betInfoMap[msg.sender];
        uint betAmountWei = betInfo.balance;
        uint multiplierLimit = betInfo.multiplier;
        uint requestId = betInfo.vrfRequestId;

        bool fulfilled;
        uint256[] memory randomWords;
        (fulfilled, randomWords) = chainlinkVRF.getRequestStatus(requestId);
        require(fulfilled==true, "VRF Not Confirmed");
        require(betAmountWei!=0, "No balance");
        uint256 randInt = randomWords[0];
        bool isVip;

        if(userLpBalanceMap[msg.sender] >= vipThreshold) {
            isVip = true;
        } else{
            isVip = false;
        }

        uint winMultiplier = getWinMultiplier(randInt);
        
        if (multiplierLimit <= winMultiplier) {
            userBalanceMapWei[msg.sender] = betAmountWei * multiplierLimit / 100;
            rewardPoolBalanceWei -= betAmountWei * (multiplierLimit-100) / 100;
        } else {
            userBalanceMapWei[msg.sender] = 0;
            rewardPoolBalanceWei += betAmountWei;
        }
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
        if(userLpBalanceMap[msg.sender]>=)
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