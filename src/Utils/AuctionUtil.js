function getStringState(state) {

    switch (state) {
        case 0:
            return "DEFAULT";
        case 1:
            console.log("util ne");
            return "RUNNING";
        case 2:
            return "FINALIZE";
        case 3:
            return "DONE";
        case 4:
            return "FAILSE";
    }
}

export default {
    getStringState
}