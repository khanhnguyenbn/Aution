
pragma solidity 0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
pragma experimental ABIEncoderV2;

library UserInformation {
    struct owner {
       string ownerName;
       string ownerPhoneNumber;
       string ownerAddress;
    }
    
    struct action {
        uint time;
        uint actionType;
        address walletAddress;
        uint amount;
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
    
    // id of auction
    uint public id;
    
    // address of owner that create this auction
    address payable private owner; 
    
    string title;
    
    uint startPrice;
    
    string description;

    // save list state that system has
    enum State{Default, Running, Finalized, Money_Transfered, Done, Faile}
    
    // save current state of auction
    State public auctionState;

    // save value of highestBidder
    uint public highestPrice;
    
    // save address of highestBidder
    address payable public highestBidder;
    
    // save address and value of bidders
    mapping(address => uint) public bids;
    
    // save address and money deposit of bidders
    mapping(address => uint) public deposit;
    
    // save address of depositer
    address payable[] public depositList;
    
    
    // save money of winner after end bidding time
    mapping(address => uint) public winnerPayment;
    
    // save owner information
    UserInformation.owner ownerInformation;
    
    // save time that owner create auction
    uint public startTime;
    
    // time to end bidding
    uint public endTime;
    
    
    // to save history of bid tracsaction
    mapping(address => uint[]) public bidsHistory;
    
    UserInformation.action[] public actionHistory;
    
    
    
    
    
      
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
    
      
    function payDeposit(uint _currentTime) public payable notOwner returns(bool) {
        
        require(auctionState == State.Running);
        require(deposit[msg.sender] == 0);
        
        deposit[msg.sender] = msg.value;
        depositList.push(msg.sender);
        
        UserInformation.action memory action;
        action.time = _currentTime;
        action.actionType = 1;
        action.walletAddress = msg.sender;
        action.amount = msg.value;
        
        actionHistory.push(action);
        
        
        return true;
        
    }
    
    
    function placeBid(uint _amount, uint _currentTime) public returns(bool) {
        require(auctionState == State.Running);
        require(msg.sender != owner);
        require(_amount >= startPrice, "your bid must greater than equal startPrice");
        
        uint currentBid = _amount;
        require(currentBid > highestPrice);
        // set the currentBid links with msg.sender
        bids[msg.sender] = currentBid;
        // update the highest price
        highestPrice = currentBid;
        highestBidder = msg.sender;
        
        bidsHistory[msg.sender].push(_amount);
        
        UserInformation.action memory action;
        action.time = _currentTime;
        action.actionType = 2;
        action.walletAddress = msg.sender;
        action.amount = _amount;
        
        actionHistory.push(action);
        
        
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
        
        for(uint i = 0; i < depositList.length; i++) {
            if(depositList[i] != highestBidder){
                
                address payable recipiant = depositList[i];
                uint value = deposit[recipiant];
                recipiant.transfer(value);
                bids[recipiant] = 0;
            }
        }
        
        auctionState = State.Finalized;
        
    }
    
    function finalizeBySystem(uint _currentTime) public {
        
        if(isAllowSystemFinalize(_currentTime)){
            for(uint i = 0; i < depositList.length; i++) {
                if(depositList[i] != highestBidder){
                
                    address payable recipiant = depositList[i];
                    uint value = deposit[recipiant];
                    recipiant.transfer(value);
                    deposit[recipiant] = 0;
                }
            }
            
            auctionState = State.Finalized;
        }
    }
    
    function payMoneyOfWinner(uint _currentTime) public payable returns(bool) {
        require(auctionState == State.Finalized);
        require(msg.sender == highestBidder, "Is not highestBidder");
        
        uint amountWinnerSend = highestPrice - deposit[msg.sender];
        require(msg.value == amountWinnerSend, "Is not highestPrice");
        
        winnerPayment[msg.sender] = msg.value;
        
        auctionState = State.Money_Transfered;
        
        UserInformation.action memory action;
        action.time = _currentTime;
        action.actionType = 3;
        action.walletAddress = msg.sender;
        action.amount = msg.value;
        
        actionHistory.push(action);
        
        return true;
    }
    
    function getDeposit(address _senderAddress) public view returns (uint) {
        if(deposit[_senderAddress] > 0) {
            return deposit[_senderAddress];
        } else {
            return 0;
        }
    }
    
    // function refunForFaileBidder(uint _currentTime) public {
    //     require(auctionState == State.Running);
    //     require(msg.sender != owner);
    //     require(_currentTime > endTime);
    //     require(bidsList.length > 0);
    //     for(uint i = 0; i < bidsList.length; i++) {
    //         if(bidsList[i] != highestBidder){
                
    //             address payable recipiant = bidsList[i];
    //             uint value = bids[recipiant];
    //             recipiant.transfer(value);
    //             bids[recipiant] = 0;
    //         }
    //     }
        
    //     auctionState = State.Finalized;
    // }
    
    function sendToOwner() public {
        
        require(auctionState == State.Money_Transfered);
        require(msg.sender == highestBidder);
        
        owner.transfer(winnerPayment[highestBidder] + deposit[msg.sender]);
        auctionState = State.Done;
        
    }
    
    function refunForHighestBidder() public {
        require(auctionState == State.Money_Transfered);
        require(msg.sender == highestBidder);
        
        highestBidder.transfer(winnerPayment[highestBidder] + deposit[highestBidder]);
        auctionState = State.Faile;
    }
    
    function isAllowDeposit(address _senderAddress, uint _currentTime) public view returns (bool) {
       
       if(auctionState == State.Running && _senderAddress != owner && deposit[_senderAddress] == 0 && _currentTime < endTime) {
           
           return true;
       } else {
           return false;
       }
    }
    
    function isAllowBid(address _senderAddress, uint _currentTime) public view returns (bool){
        
        if (_senderAddress != owner && auctionState == State.Running && deposit[_senderAddress] > 0 && _currentTime < endTime){
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
    
    function isAllowDisplayWinner() public view returns (bool) {
        
        if(auctionState != State.Running) {
            return true;
        } else {
            return false;
        }
    }
    
    function isAllowWinnerDoAfter(address _senderAddress) public view returns (bool){
        if (auctionState == State.Money_Transfered && _senderAddress == highestBidder) {
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
    
    function isAllowWinnerTransferMoney(address _senderAddress) public view returns (bool) {
        
        if(auctionState == State.Finalized && _senderAddress == highestBidder) {
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
    
    // function getLengthOfBidList() public view returns (uint) {
        
    //     return bidsList.length;
    // }
    
    function getWinner() public view returns(address) {
        
        return highestBidder;
    }
    
    
    function getActionHistory() public view returns(UserInformation.action[] memory) {
        return actionHistory;
    }
}