const { BetToken } = require("../betToken");
const { getSigner, BscBets } = require("../bscbets");

const BSC_PROVIDER = "https://data-seed-prebsc-1-s3.binance.org:8545/";
const PRIVATE_KEY = "0xdd0945d3d375a1aeafd66785d7854052fb9a45d5b6cee8249f11f6d461c8abd5";
const ADDRESS = "0xA57d9222Fbd1BDbfc03e6CEfb36365E148c93F62";

const signer = getSigner(PRIVATE_KEY, BSC_PROVIDER);

const bscBets = new BscBets(signer);
const betToken = new BetToken(signer);

const approve = async(amount) => {
    const approve = await betToken.approve(amount);
}

const deposit = async(amount) =>{ 
    const approve = await betToken.approve(amount);
    const txHash = await bscBets.adminDepositRewardPool(amount).then(console.log);
}

approve(10000000000000000000000);