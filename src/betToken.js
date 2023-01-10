const { ethers } = require("ethers");
const { betContractData } = require("./betTokenContract.js");
const { contractData } = require("./contract");
const getSigner = (PRIVATE_KEY, BSC_PROVIDER) => {
    const provider = ethers.getDefaultProvider(BSC_PROVIDER);
    const signer = new ethers.Wallet(PRIVATE_KEY, provider);
    return signer;
}

class BetToken {
    constructor(signer) {
        this.contract = new ethers.Contract(
            betContractData.address,
            betContractData.abi,
            signer
        );

        this.bscBetsAddress = contractData.address;
        console.log(this.bscBetsAddress);
    }

    approve = async(amount) => {
        const tx = await this.contract.approve(this.bscBetsAddress, amount);
        const txHash = await tx.hash;
        await tx.wait();
        return txHash;
    }
}

module.exports = { BetToken };