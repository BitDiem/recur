pragma solidity ^0.5.0;

import "../../lib/date/BokkyPooBahsDateTimeLibrary.sol";

library DateTime {

    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;

    /// Code based on https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    function isValidMonthAndYear(uint month, uint year) internal pure returns (bool) {
        return (year >= 1970 && month > 0 && month <= 12);
    }

    function isValidTime(uint hour, uint minute, uint second) internal pure returns (bool) {
        return (
            hour > 0 && hour < 25 &&
            minute > 0 && minute < 61 &&
            second > 0 && second < 61
        );
    }

    // note that no overflow check is performed.  Make sure to call "isValidTime" prior to using this function
    function totalSeconds(uint hour, uint minute, uint second) internal pure returns (uint) {
        return 
            hour * SECONDS_PER_HOUR + 
            minute * SECONDS_PER_MINUTE + 
            second;
    }

    // BokkyPooBahsDateTimeLibrary call does check for overflow
    function add(uint timestamp, uint _seconds) internal pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary.addSeconds(timestamp, _seconds);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
    }

    // returns the Min between the provided day and total days in the given month
    function constrainToDaysInMonth(uint year, uint month, uint day) internal pure returns (uint adjustedPaymentDay) {
        adjustedPaymentDay = day;
        if (adjustedPaymentDay > 28) {
            uint daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(year, month);
            if (adjustedPaymentDay > daysInMonth) {
                adjustedPaymentDay = daysInMonth;
            }
        }
    }

}