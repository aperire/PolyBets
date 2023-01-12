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
    address admin;
    constructor() {
        admin = msg.sender;
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
    address BET = 0x697d2FE6901a76DA03D92f1a2764Fe223fE7d456;

    // Probability distribution array (100~10000)
    uint [] vip1ProbabilityArray;

    uint [] vip2ProbabilityArray;

    uint [] vip3ProbabilityArray;

    uint [] temporaryVipProbabilityArray;
    
    // Min LP Token for VIP
    uint minLpToken = 10000;

    // Min total volume
    uint minBetVolume = 10000;

    function getUserInfo() public view returns (UserInfo _userInfo){
        _userInfo=userInfoMap[msg.sender];
        return _userInfo;
    }

    function getBetInfo() public view returns (BetInfo _betInfo){
        _betInfo=betInfoMap[msg.sender];
        return _betInfo;
    }

    function getVip1ProbabilityArray() public view returns (uint [] _vip1ProbabilityArray){
        _vip1ProbabilityArray=vip1ProbabilityArray;
        return _vip1ProbabilityArray;
    }

    function getVip1ProbabilityArrayLength() public view returns (uint _vip1ProbabilityArrayLength){
        _vip1ProbabilityArrayLength=vip1ProbabilityArray.length;
        return _vip1ProbabilityArrayLength;
    }

    function getVip2ProbabilityArray() public view returns (uint [] _vip2ProbabilityArray){
        _vip2ProbabilityArray=vip2ProbabilityArray;
        return _vip2ProbabilityArray;
    }

    function getVip2ProbabilityArrayLength() public view returns (uint _vip2ProbabilityArrayLength){
        _vip2ProbabilityArrayLength=vip2ProbabilityArray.length;
        return _vip2ProbabilityArrayLength;
    }

    function getVip3ProbabilityArray() public view returns (uint [] _vip3ProbabilityArray){
        _vip3ProbabilityArray=vip3ProbabilityArray;
        return _vip1ProbabilityArray;
    }

    function getVip3ProbabilityArrayLength() public view returns (uint _vip3ProbabilityArrayLength){
        _vip3ProbabilityArrayLength=vip3ProbabilityArray.length;
        return _vip3ProbabilityArrayLength;
    }

    function getTemporaryVipProbabilityArray() public view returns (uint [] _temporaryVipProbabilityArray){
        _temporaryVipProbabilityArray=temporaryVipProbabilityArray;
        return _temporaryVipProbabilityArray;
    }

    function getTemporaryVipProbabilityArrayLength() public view returns (uint _temporaryVipProbabilityArrayLength){
        _temporaryVipProbabilityArrayLength=temporaryVipProbabilityArray.length;
        return _vip3ProbabilityArrayLength;
    }


    // Onlyowner
    function updateMinLpToken(uint _minLpToken) public {
        require(msg.sender==admin, "Only admin can access");
        minLpToken=_minLpToken;
    }

    function updateMinBetVolume(uint _minBetVolume) public {
        require(msg.sender==admin, "Only admin can access");
        minBetVolume=_minBetVolume;
    }

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
        if (userInfoMap[referrer].netVolume>=minLpToken) {
            UserInfo memory userInfo = UserInfo(1, 0, true, 10);
            userInfoMap[msg.sender] = userInfo;
        }
        else {
            UserInfo memory userInfo = UserInfo(1, 0, true, 5);
            userInfoMap[msg.sender] = userInfo;
        }
    }

    function getWinMultiplier(uint256 _randInt) public returns (uint winMultiplier){
        uint _vipLevel=userInfoMap[msg.sender].vipLevel;
        if (userInfoMap[msg.sender].isTemporaryVip){
            winMultiplier = temporaryVipProbabilityArray[_randInt%temporaryVipProbabilityArray.length];
            userInfoMap[msg.sender].temporaryVipCount-=1;
            if(userInfoMap[msg.sender].temporaryVipCount==0){
                userInfoMap[msg.sender].isTemporaryVip=false;
            }
        } else if (_vipLevel==1) {
            winMultiplier = vip1ProbabilityArray[_randInt%vip1ProbabilityArray.length];
        } else if(_vipLevel==2){
            winMultiplier = vip2ProbabilityArray[_randInt%vip2ProbabilityArray.length];
        } else{
            winMultiplier = vip3ProbabilityArray[_randInt%vip3ProbabilityArray.length];
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

        userInfoMap[msg.sender].netVolume+=_betAmountWei;
        if(userInfoMap[msg.sender].vipLevel==2 && userInfoMap[msg.sender].netVolume>=minBetVolume){
            userInfoMap[msg.sender].vipLevel=3;
        }
        // VRF
        chainlinkVRF.requestRandomWords();
        uint256 requestId = chainlinkVRF.lastRequestId();

        BetInfo memory betInfo = BetInfo(_betAmountWei, _multiplierLimit, requestId);
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

        if(userLpBalanceMap[msg.sender] >= minLpToken) {
            isVip = true;
        } else{
            isVip = false;
        }

        uint winMultiplier = getWinMultiplier(randInt);
        
        if (multiplierLimit <= winMultiplier) {
            uint newBetAmountWei = betAmountWei * multiplierLimit / 100;
            betInfoMap[msg.sender].balance = newBetAmountWei;
            rewardPoolBalanceWei -= betAmountWei * (multiplierLimit-100) / 100;
        } else {
            betInfoMap[msg.sender].balance = 0;
            betInfoMap[msg.sender].multiplier = 0;
            betInfoMap[msg.sender].vrfRequestId = 0;
            rewardPoolBalanceWei += betAmountWei;
        }
    }

    function withdrawBetReward() public payable {
        uint currentBalance = betInfoMap[msg.sender].balance;
        require(ERC20(BET).approve(msg.sender, currentBalance));
        require(ERC20(BET).transferFrom(address(this), msg.sender, currentBalance), "Transfer Unsuccesful");
        betInfoMap[msg.sender].balance = 0; 
    }

    function adminDepositBetRewardPool(uint _amount) public {
        require(msg.sender==admin, "Only admin can access");
        require(ERC20(BET).transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        rewardPoolBalanceWei += _amount;
    }

    function adminWithdrawBetRewardPool(uint _amount) public payable{
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

    function adminDepositLpRewards(uint _amount) public {
        require(ERC20(BET).transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        rewardReserveBalance += _amount;
    }

    function adminWithdrawLpRewards(uint _amount) public payable{
        require(ERC20(BET).approve(msg.sender, _amount));
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        rewardReserveBalance -= _amount;
    }

    function depositLpToken(uint _amount) public {
        require(BET_USDC.transferFrom(msg.sender, address(this), _amount), "Transfer Unsuccesful");
        userLpBalanceMap[msg.sender] += _amount;
        if(userInfoMap[msg.sender].vipLevel==1 && userLpBalanceMap[msg.sender]>=minLpToken){
            userInfoMap[msg.sender].vipLevel=2;
        }
    }

    function withdrawLpToken(uint _amount) public payable{
        require(BET_USDC.approve(msg.sender, _amount));
        require(BET_USDC.transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        userLpBalanceMap[msg.sender] -= _amount;
        if (userLpBalanceMap[msg.sender]<minLpToken){
            userInfoMap[msg.sender].vipLevel=1;
        }
    }

    function withdrawLpReward(uint _amount) public {
        require(ERC20(BET).approve(msg.sender, _amount));
        require(ERC20(BET).transferFrom(address(this), msg.sender, _amount), "Transfer Unsuccesful");
        userFarmingRewardMap[msg.sender] -= _amount;
    }
}