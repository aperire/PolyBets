const { ethers } = require("ethers");
const { contractData } = require("./contract.js");

const getSigner = (PRIVATE_KEY, BSC_PROVIDER) => {
    const provider = ethers.getDefaultProvider(BSC_PROVIDER);
    const signer = new ethers.Wallet(PRIVATE_KEY, provider);
    return signer;
}

class BscBets {
    constructor(signer) {
        this.contract = new ethers.Contract(
            contractData.address,
            contractData.abi,
            signer
        );
    }

    // View Function
    getUserBalance = async(userAddress) => {
        const userBalance = await this.contract.userBalanceMap(userAddress);
        return userBalance;
    }

    getRewardPoolBalance = async() => {
        const rewardPoolBalance = await this.contract.rewardPoolBalance;
        return rewardPoolBalance;
    }

    // Global Function
    updateProbabilityArray = async(probabilityArray) => {
        const tx = await this.contract.updateProbabilityArray(probabilityArray);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    updateVipProbabilityArray = async(vipProbabilityArray) => {
        const tx = await this.contract.updateVipProbabilityArray(vipProbabilityArray);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    updateGlobalSeed = async(seed) => {
        const tx = await this.contract.updateGlobalSeed(seed);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    // User Function
    createBet = async(betAmount, multiplierLimit) => {
        const tx = await this.contract.createBet(betAmount, multiplierLimit);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    withdrawReward = async() => {
        const tx = await this.contract.withdrawReward();
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    // Admin Function
    adminDepositRewardPool = async(amount) => {
        const tx = await this.contract.adminDepositRewardPool(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }
    adminWithdrawRewardPool = async(amount) => {
        const tx = await this.contract.adminWithdrawRewardPool(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    /*
    LP Token Farming SDK
    */

    // View Function
    getUserLpBalance = async(userAddress) => {
        const userLpBalance = await this.contract.userLpBalanceMap(userAddress);
        return userLpBalance;
    }

    getUserRewardBalance = async(userAddress) => {
        const userRewardBalance = await this.contract.userFarmingRewardMap(userAddress);
        return userRewardBalance; 
    }

    getRewardEmissionPerDay = async() => {
        const rewardEmissionPerDay = await this.contract.rewardEmissionPerDay;
        return rewardEmissionPerDay;
    }

    getNetLpTokenBalance = async() => {
        const netLpTokenBalance = await this.contract.netLpTokenBalance;
        return netLpTokenBalance;
    }

    getRewardReserveBalance = async() => {
        const rewardReserveBalance = await this.contract.rewardReserveBalance;
        return rewardReserveBalance;
    }

    getLastUpdateTs = async() => {
        const lastUpdateTs = await this.contract.lastUpdateTs;
        return lastUpdateTs;
    }

    // Global Function
    updateRewards = async() => {
        const tx = await this.contract.updateRewards();
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    // Admin Function
    setRewardEmissionPerDay = async(amount) => {
        const tx = await this.contract.setRewardEmissionPerDay(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    adminDepositRewards = async(amount) => {
        const tx = await this.contract.adminDepositRewards(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    adminWithdrawRewards = async(amount) => {
        const tx = await this.contract.adminWithdrawRewards(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    // User Function
    depositLpToken = async(amount) => {
        const tx = await this.contract.depositLpToken(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    withdrawLpToken = async(amount) => {
        const tx = await this.contract.withdrawLpToken(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }

    withdrawReward = async(amount) => {
        const tx = await this.contract.withdrawReward(amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }
}

module.exports = { getSigner, BscBets };