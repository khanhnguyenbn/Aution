function getStringState(state) {

    switch (state) {
        case 0:
            return "DEFAULT";
        case 1:
            return "RUNNING";
        case 2:
            return "FINALIZED - Waiting for transfer money";
        case 3:
            return "Money was transfered";
        case 4:
            return "DONE";
        case 5:
            return "FAILSE";
    }
}

export default {
    getStringState
}