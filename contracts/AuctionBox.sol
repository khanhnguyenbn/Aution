
pragma solidity 0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
pragma experimental ABIEncoderV2;

library UserInformation {
    struct owner {
       string ownerName;
       string ownerPhoneNumber;
       string ownerAddress;
    }    
}

contract AuctionBox {
    
    uint public count;
    Auction[] public auctions;
   
    function createAuction (
        string memory _title,
        uint _startPrice,
        string memory _description,
        UserInformation.owner memory _ownerInformation,
        uint _startTime,
        uint _endTime
        ) public{
            count = count + 1;
        // set the new instance
        Auction newAuction = new Auction(count, msg.sender,_title, _startPrice, _description, _ownerInformation, _startTime, _endTime);
        // push the auction address to auctions array
        auctions.push(newAuction);
    }
    
    function returnAllAuctions() public view returns(Auction[] memory){
        return auctions;
    }
    
    function getAuctionById(uint _id) public view returns(Auction) {
        for(uint i = 0; i < auctions.length; i++) {
            if(auctions[i].getId() == _id) {
                return auctions[i];
            }
        }
    }
    
    function isHasAuctionOverTime(uint _currentTime) public view returns (bool){
        for(uint i = 0; i < auctions.length; i++) {
            if (auctions[i].isAllowSystemFinalize(_currentTime)) {
                return true;
            }
        }
        
        return false;
    }
    
    function finalizeWhenOverTime(uint _currentTime) public {
        
        for(uint i = 0; i < auctions.length; i++) {
            if(auctions[i].isAllowSystemFinalize(_currentTime)){
                auctions[i].finalizeBySystem(_currentTime);
            }
        }
    }
    
}

contract Auction {
    
    using SafeMath for uint256;
    
    uint public id;
    address payable private owner; 
    string title;
    uint startPrice;
    string description;

    enum State{Default, Running, Finalized, Done, Faile}
    State public auctionState;

    uint public highestPrice;
    address payable public highestBidder;
    mapping(address => uint) public bids;
    address payable[] public bidsList;
    
    // string public ownerName;
    // string public ownerPhoneNumber;
    // string public ownerAddress;
    
    UserInformation.owner ownerInformation;
    
    uint public startTime;
    uint public endTime;
    
    
    // to save history of bid tracsaction
    mapping(address => uint[]) public bidsHistory;
    
    /** @dev constructor to creat an auction
      * @param _owner who call createAuction() in AuctionBox contract
      * @param _title the title of the auction
      * @param _startPrice the start price of the auction
      * @param _description the description of the auction
      */
      
    constructor(
        uint _id,
        address payable _owner,
        string memory _title,
        uint _startPrice,
        string memory _description,
        UserInformation.owner memory _ownerInformation,
        uint _startTime,
        uint _endTime
        
        ) public {
        // initialize auction
        id = _id;
        owner = _owner;
        title = _title;
        startPrice = _startPrice;
        description = _description;
        auctionState = State.Running;
        
        // ownerName = _ownerName;
        // ownerPhoneNumber = _ownerPhoneNumber;
        // ownerAddress = _ownerAddress;
        
        ownerInformation = _ownerInformation;
        
        startTime = _startTime;
        endTime = _endTime;
    }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    
    /** @dev Function to place a bid
      * @return true
      */
    
    function placeBid() public payable notOwner returns(bool) {
        require(auctionState == State.Running);
        // require(msg.value > startPrice);
        // update the current bid
        // uint currentBid = bids[msg.sender] + msg.value;
        
        if(bids[msg.sender] == 0){
            bidsList.push(msg.sender);
        }
        uint currentBid = bids[msg.sender].add(msg.value);
        require(currentBid > highestPrice);
        // set the currentBid links with msg.sender
        bids[msg.sender] = currentBid;
        // update the highest price
        highestPrice = currentBid;
        highestBidder = msg.sender;
        
        bidsHistory[msg.sender].push(msg.value);
        
        return true;
    }
    
    function finalizeAuction() public{
        // //the owner and bidders can finalize the auction.
        // require(msg.sender == owner || bids[msg.sender] > 0);
        
        // address payable recipiant;
        // uint value;
        
        // // owner can get highestPrice
        // if(msg.sender == owner){
        //     recipiant = owner;
        //     value = highestPrice;
        // }
        // // highestBidder can get no money
        // else if (msg.sender == highestBidder){
        //     recipiant = highestBidder;
        //     value = 0;
        // }
        // // Other bidders can get back the money 
        // else {
        //     recipiant = msg.sender;
        //     value = bids[msg.sender];
        // }
        // // initialize the value
        // bids[msg.sender] = 0;
        // recipiant.transfer(value);
        // auctionState = State.Finalized;
        
        require(auctionState == State.Running);
        require(msg.sender == owner);
        
        for(uint i = 0; i < bidsList.length; i++) {
            if(bidsList[i] != highestBidder){
                
                address payable recipiant = bidsList[i];
                uint value = bids[recipiant];
                recipiant.transfer(value);
                bids[recipiant] = 0;
            }
        }
        
        auctionState = State.Finalized;
        
    }
    
    function finalizeBySystem(uint _currentTime) public {
        
        if(isAllowSystemFinalize(_currentTime)){
            for(uint i = 0; i < bidsList.length; i++) {
                if(bidsList[i] != highestBidder){
                
                    address payable recipiant = bidsList[i];
                    uint value = bids[recipiant];
                    recipiant.transfer(value);
                    bids[recipiant] = 0;
                }
            }
            
            auctionState = State.Finalized;
        }
    }
    
    function refunForFaileBidder(uint _currentTime) public {
        require(auctionState == State.Running);
        require(msg.sender != owner);
        require(_currentTime > endTime);
        require(bidsList.length > 0);
        for(uint i = 0; i < bidsList.length; i++) {
            if(bidsList[i] != highestBidder){
                
                address payable recipiant = bidsList[i];
                uint value = bids[recipiant];
                recipiant.transfer(value);
                bids[recipiant] = 0;
            }
        }
        
        auctionState = State.Finalized;
    }
    
    function sendToOwner() public {
        
        require(auctionState == State.Finalized);
        require(msg.sender == highestBidder);
        
        owner.transfer(bids[highestBidder]);
        auctionState = State.Done;
        
    }
    
    function refunForHighestBidder() public {
        require(auctionState == State.Finalized);
        require(msg.sender == highestBidder);
        
        highestBidder.transfer(bids[highestBidder]);
        auctionState = State.Faile;
    }
    
    function isAllowBid(address _senderAddress, uint _currentTime) public view returns (bool){
        
        if (_senderAddress != owner && auctionState == State.Running && _currentTime < endTime){
            return true;
        } else {
            return false;
        }
    }
    
    function isAllowFinalize(address _senderAddress) public view returns (bool){
        
        if(_senderAddress == owner && auctionState == State.Running) {
            return true;
        } else {
            return false;
        }
    }
    
    function isAllowRefun(address _senderAddress, uint _currentTime) public view returns (bool) {
        if (_senderAddress != owner && _currentTime > endTime && auctionState == State.Running) {
            return true;
        } else {
            return false;
        }
    }
    
    function isAllowWinnerDoAfter(address _senderAddress) public view returns (bool){
        if (auctionState == State.Finalized && _senderAddress == highestBidder) {
            return true;
        } else {
            return false;
        }
    }
    
    function isAllowSystemFinalize (uint _currentTime) public view returns (bool){
        if (auctionState == State.Running && _currentTime >= endTime) {
            return true;
        } else {
            return false;
        }
    }
    
    
    
    
    
    /** @dev Function to return the contents od the auction
      * @return the title of the auction
      * @return the start price of the auction
      * @return the description of the auction
      * @return the state of the auction 
      */    
    
    function returnContents() public view returns( 
        uint,
        string memory,
        uint,
        uint,
        string memory,
        State,
        UserInformation.owner memory,
        uint,
        uint
        ) {
        return (
            id,
            title,
            startPrice,
            highestPrice,
            description,
            auctionState,
            ownerInformation,
            startTime,
            endTime
        );
    }
    
    function getId() public view returns(uint){
        return id;
    }
    
    function getHighestPrice() public view returns(uint) {
        
        return highestPrice;
    }
    
    function getBidHistoryByAdress(address _senderAddress) public view returns(uint[] memory){
        
        return bidsHistory[_senderAddress];
    }
    
    function getLengthOfBidList() public view returns (uint) {
        
        return bidsList.length;
    }
    
    function getWinner() public view returns(address) {
        
        return highestBidder;
    }
}