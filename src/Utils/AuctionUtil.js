
const STATE = {
    RUNNING: 1,
    FINALIZED: 2,
    MONEY_WAS_TRANSFERED: 3,
    DONE: 4,
    FAILSE: 5
};

const ACTION = {
    DEPOSIT: 1,
    BID: 2,
    TRANFER: 3
};

function getStringState(state) {

    switch (state) {
        case 0:
            return "DEFAULT";
        case 1:
            return "RUNNING";
        case 2:
            return "FINALIZED - Waiting for transfer money";
        case 3:
            return "Bidder transferred money";
        case 4:
            return "DONE";
        case 5:
            return "FAILSE";
    }
};

function getStringActionType(actionType){
    switch (actionType) {
        case 0:
            return "DEFAULT";
        case 1:
            return "Deposit";
        case 2:
            return "Bid";
        case 3:
            return "Transfer";
    }
}

export default {
    getStringState,
    getStringActionType,
    STATE,
    ACTION
}