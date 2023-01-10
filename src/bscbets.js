const { ethers } = require("ethers");
const contractData = require("./contract.js");

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
}