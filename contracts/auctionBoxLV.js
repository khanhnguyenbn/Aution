import web3 from './web3';

const address = '0xBe5574e562a823fEfDA4f20988635a9DBE39F7ee'; // THE CONTRACT ADDRESS
const abi = [
	{
		"inputs": [
			{
				"internalType": "bytes",
				"name": "_id",
				"type": "bytes"
			}
		],
		"name": "createAuction",
		"outputs": [],
		"stateMutability": "nonpayable",
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
		"name": "auctionLVs",
		"outputs": [
			{
				"internalType": "contract AuctionLV",
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
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "returnAllAuctions",
		"outputs": [
			{
				"internalType": "contract AuctionLV[]",
				"name": "",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]; // THE ABI

const instance = new web3.eth.Contract(abi, address);

export default instance;
