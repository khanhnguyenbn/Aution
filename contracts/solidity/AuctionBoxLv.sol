pragma solidity ^0.6.0;

contract AuctionBoxLV {

    AuctionLV[] public auctionLVs;
  
    function createAuction (bytes memory _id) public{
        AuctionLV newAuction = new AuctionLV(_id);
        // push the auction address to auctions array
        auctionLVs.push(newAuction);
    }
    
    function returnAllAuctions() public view returns(AuctionLV[] memory){
        return auctionLVs;
    }
    
    function getAuctionById(bytes memory _id) public view returns(AuctionLV) {
        for(uint i = 0; i < auctionLVs.length; i++) {
            if(keccak256(auctionLVs[i].getId()) == keccak256(_id)) {
                return auctionLVs[i];
            }
        }
    }
    
}

contract AuctionLV {
    
    
    bytes public id;
    
    mapping(address => uint) public deposit;
    
    mapping(address => uint) public monneyOfWinner;
    
      
    constructor(bytes memory _id ) public {
        id = _id;
    }
    
      
    function payDeposit() public payable returns(bool) {
        
        require(deposit[msg.sender] == 0);
        
        deposit[msg.sender] = msg.value;
        
        return true;
        
    }
    
    function refunForLoser(address payable[] memory loserList) public {
        
        for(uint i = 0; i < loserList.length; i++) {
            if(deposit[loserList[i]] != 0) {
                loserList[i].transfer(deposit[loserList[i]]);
                
                deposit[loserList[i]] = 0;
            }
        }
        
    }
    
    function payMoney() public payable returns(bool) {
        
        monneyOfWinner[msg.sender] = msg.value;
        
        return true;
    }
    
    function refundForWinner() public {
        
        msg.sender.transfer(monneyOfWinner[msg.sender] + deposit[msg.sender]);
    }
    
    function transferToOwner(address payable _owner) public {
        
        _owner.transfer(deposit[msg.sender] + monneyOfWinner[msg.sender]);
    }
    
    
    
    function isAllowDeposit(address _sender) public view returns (bool) {
       
       if (deposit[_sender] == 0) {
           return true;
       } else {
           return false;
       }
    }
    
    function isAllowBid(address _sender) public view returns (bool) {
       
       if (deposit[_sender] != 0) {
           return true;
       } else {
           return false;
       }
    }
    
    function getId() public view returns (bytes memory) {
       
       return id;
    }
    
    
    
    
}