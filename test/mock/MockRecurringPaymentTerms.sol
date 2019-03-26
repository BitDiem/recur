pragma solidity ^0.5.0;

import "../../contracts/terms/Seconds.sol";

contract MockRecurringPaymentTerms is Seconds {

    uint private currentTimeStamp;

    constructor(
        uint amount,
        uint nextPaymentDueTimestamp,
        uint secondsIncrement
    )
        Seconds(amount, nextPaymentDueTimestamp, secondsIncrement)
        public
    {
    }

    function setCurrentTimeStamp(uint val) public {
        currentTimeStamp = val;
    }

    function _getCurrentTimeInUnixSeconds() internal view returns (uint) {
        return currentTimeStamp;
    }

}