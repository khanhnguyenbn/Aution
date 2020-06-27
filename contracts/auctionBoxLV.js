import web3 from './web3';

const address = '0xa630b85A7433949bF953fF314F3333C4e2749137'; // THE CONTRACT ADDRESS
const abi = [
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "bytes",
				"name": "_id",
				"type": "bytes"
			}
		],
		"name": "createAuction",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "bytes",
				"name": "_id",
				"type": "bytes"
			},
			{
				"internalType": "address payable[]",
				"name": "loserList",
				"type": "address[]"
			}
		],
		"name": "refunForLoser",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "auctionLVs",
		"outputs": [
			{
				"internalType": "contract AuctionLV",
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"internalType": "bytes",
				"name": "_id",
				"type": "bytes"
			}
		],
		"name": "getAuctionById",
		"outputs": [
			{
				"internalType": "contract AuctionLV",
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "returnAllAuctions",
		"outputs": [
			{
				"internalType": "contract AuctionLV[]",
				"name": "",
				"type": "address[]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]; // THE ABI

const instance = new web3.eth.Contract(abi, address);

export default instance;
