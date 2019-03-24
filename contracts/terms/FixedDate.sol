pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/date/BokkyPooBahsDateTimeLibrary.sol";

/**
 * @title FixedDate
 * @dev Base contract for specifying an exact datetime that payment is due on.  
 * Year, month, and day of next payment can be manipulated by child contracts.
 * Contract stores the year, month, day and total seconds offset, in addition to a timestamp value.
 * Justification: saves a call to BokkyPooBahsDateTimeLibrary._daysToDate, 
 * at the expense of using a bit more storage (4 additional vs. just storing a timestamp)
 */
contract FixedDate is PaymentObligation {

    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;

    uint internal _nextPaymentYear;
    uint internal _nextPaymentMonth;
    uint internal _nextPaymentDay;

    uint private _secondsOffset;
    uint private _nextPaymentTimestamp;
    uint private _amount;

    event NewPaymentDue(uint amount, uint paymentDueDate);

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond
    )
        public
    {
        require(amount > 0);
        require(_isValidMonthAndYear(nextPaymentMonth, nextPaymentYear));
        require(nextPaymentDay > 0);

        _amount = amount;
        _nextPaymentYear = nextPaymentYear;
        _nextPaymentMonth = nextPaymentMonth;
        _nextPaymentDay = nextPaymentDay;

        _secondsOffset = _getTotalSeconds(nextPaymentHour, nextPaymentMinute, nextPaymentSecond);
        _calculateNextPaymentTimestamp();
    }

    function _calculateOutstandingAmount() internal returns (uint) {
        if (_getCurrentTimeInUnixSeconds() < _nextPaymentTimestamp)
            return 0;

        _advance();
        _calculateNextPaymentTimestamp();

        emit NewPaymentDue(_amount, _nextPaymentTimestamp);
        
        return _amount;
    }

    /// Wrap the call and make it internal - makes it easy to create a derived mock class to test exact hypothetical dateTimes
    function _getCurrentTimeInUnixSeconds() internal view returns (uint) {
        return now;
    }

    function _advance() internal;

    /// saving the year / month / day saves a call to BokkyPooBahsDateTimeLibrary._daysToDate, 
    /// at the expense of using a bit more storage (4x or 7x vs. just storing a timestamp)
    function _calculateNextPaymentTimestamp() private {
        // adjust for the days of month for payment days greater than 28 (since all months have at least 28 days)
        uint adjustedPaymentDay = _nextPaymentDay;
        if (_nextPaymentDay > 28) {
            uint daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(_nextPaymentYear, _nextPaymentMonth);
            if (_nextPaymentDay > daysInMonth) {
                adjustedPaymentDay = daysInMonth;
            }
        }

        // create the timestamp from year, month, and adjusted date
        uint date = BokkyPooBahsDateTimeLibrary.timestampFromDate(
            _nextPaymentYear,
            _nextPaymentMonth,
            adjustedPaymentDay
        );
        _nextPaymentTimestamp = date + _secondsOffset;
    }

    /// Code based on https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    function _isValidMonthAndYear(uint month, uint year) private pure returns (bool) {
        return (year >= 1970 && month > 0 && month <= 12);
    }

    function _getTotalSeconds(uint hour, uint minute, uint second) private pure returns (uint) {
        return 
            hour * SECONDS_PER_HOUR + 
            minute * SECONDS_PER_MINUTE + 
            second;
    }

}