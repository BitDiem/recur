pragma solidity ^0.5.0;

import "../../contracts/terms/datetime/Seconds.sol";
import "../../contracts/lib/date/DateTime.sol";

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

    function setCurrentDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public {
        currentTimeStamp = DateTime.timestampFromDateTime(year, month, day, hour, minute, second);
    }

    function _getCurrentTimeInUnixSeconds() internal view returns (uint) {
        return currentTimeStamp;
    }

}