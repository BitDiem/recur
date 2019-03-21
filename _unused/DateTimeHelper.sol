pragma solidity ^0.5.0;

import "../../lib/date/BokkyPooBahsDateTimeLibrary.sol";

library DateTimeHelper {

    function adjustedTimestampFromDate(uint year, uint month, uint day) external pure returns (uint) {
        // adjust for the days of month for payment days greater than 28 (since all months have at least 28 days)
        uint adjustedPaymentDay = day;
        if (adjustedPaymentDay > 28) {
            uint daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(year, month);
            if (adjustedPaymentDay > daysInMonth) {
                adjustedPaymentDay = daysInMonth;
            }
        }

        // create the timestamp from year, month, and adjusted date
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(
            year,
            month,
            adjustedPaymentDay
        );
    }

    function getDaysInMonth(uint year, uint month) external pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary._getDaysInMonth(year, month);
    }

    function timestampFromDate(uint year, uint month, uint day) external pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
    }

}