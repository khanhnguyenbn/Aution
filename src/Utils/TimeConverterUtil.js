function toTimeStamp(dateTime) {
    return Date.parse(dateTime);
}

function toString (timeStamp) {
    var ts = new Date(timeStamp);

    return ts.toLocaleString();
}

export default {
    toTimeStamp,
    toString
}