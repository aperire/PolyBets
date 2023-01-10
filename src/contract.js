const contractData = {
	"address": "0x20fCaA8b0a96B4FA298aE0770e3940D56293f714",
	"abi": [
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "adminDepositRewardPool",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "adminDepositRewards",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "adminWithdrawRewardPool",
			"outputs": [],
			"stateMutability": "payable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "adminWithdrawRewards",
			"outputs": [],
			"stateMutability": "payable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_betAmount",
					"type": "uint256"
				},
				{
					"internalType": "uint256",
					"name": "_multiplierLimit",
					"type": "uint256"
				}
			],
			"name": "createBet",
			"outputs": [
				{
					"internalType": "bool",
					"name": "win",
					"type": "bool"
				}
			],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "depositLpToken",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "setRewardEmissionPerDay",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "string",
					"name": "_seed",
					"type": "string"
				}
			],
			"name": "updateGlobalSeed",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "updateRewards",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "withdrawLpToken",
			"outputs": [],
			"stateMutability": "payable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_amount",
					"type": "uint256"
				}
			],
			"name": "withdrawReward",
			"outputs": [],
			"stateMutability": "nonpayable",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "withdrawReward",
			"outputs": [],
			"stateMutability": "payable",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "_number",
					"type": "uint256"
				}
			],
			"name": "decimalWrapper",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "number",
					"type": "uint256"
				}
			],
			"stateMutability": "pure",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "getRandomInt",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "randomInt",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "bool",
					"name": "_isVip",
					"type": "bool"
				}
			],
			"name": "getWinMultiplier",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "winMultiplier",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [],
			"name": "rewardPoolBalance",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"name": "userAddressArray",
			"outputs": [
				{
					"internalType": "address",
					"name": "",
					"type": "address"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "address",
					"name": "",
					"type": "address"
				}
			],
			"name": "userBalanceMap",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "address",
					"name": "",
					"type": "address"
				}
			],
			"name": "userFarmingRewardMap",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		},
		{
			"inputs": [
				{
					"internalType": "address",
					"name": "",
					"type": "address"
				}
			],
			"name": "userLpBalanceMap",
			"outputs": [
				{
					"internalType": "uint256",
					"name": "",
					"type": "uint256"
				}
			],
			"stateMutability": "view",
			"type": "function"
		}
	]
}
module.exports = { contractData };