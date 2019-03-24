pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/date/DateTime.sol";
import "../lib/date/MockableCurrentTime.sol";

/**
 * @title FixedDate
 * @dev Base contract for specifying an exact datetime that payment is due on.  
 * Year and month of next payment can be manipulated by child contracts.
 * Contract stores the year, month, day and total seconds offset, in addition to a timestamp value.
 * Justification: saves a call to BokkyPooBahsDateTimeLibrary._daysToDate, 
 * at the expense of using a bit more storage (4 additional uint's vs. just storing a timestamp).
 * NOTE: For this contract as well as those deriving from it, specifying a @nextPaymentDay greater than 31 will ensure 
 * that payment is due on the last day of the month, regardless of how many days are in that month.
 */
contract FixedDate is PaymentObligation, MockableCurrentTime {

    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;

    uint internal _nextPaymentYear;
    uint internal _nextPaymentMonth;

    uint private _nextPaymentDay;
    uint private _secondsOffset;
    uint private _nextPaymentTimestamp;
    uint private _amount;

    event PaymentDue(uint paymentDueDate, uint amount);

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
        require(DateTime.isValidMonthAndYear(nextPaymentMonth, nextPaymentYear));
        require(nextPaymentDay > 0);
        require(DateTime.isValidTime(nextPaymentHour, nextPaymentMinute, nextPaymentSecond));

        _amount = amount;
        _nextPaymentYear = nextPaymentYear;
        _nextPaymentMonth = nextPaymentMonth;
        _nextPaymentDay = nextPaymentDay;

        _secondsOffset = DateTime.totalSeconds(nextPaymentHour, nextPaymentMinute, nextPaymentSecond);
        _calculateNextPaymentTimestamp();
    }

    function _calculateOutstandingAmount() internal returns (uint) {
        if (_getCurrentTimeInUnixSeconds() < _nextPaymentTimestamp)
            return 0;

        uint currentPaymentDue = _nextPaymentTimestamp;
        _advance();
        _calculateNextPaymentTimestamp();    
        emit PaymentDue(currentPaymentDue, _amount);
        return _amount;
    }

    /// override this function to change month or year of next payment due date
    function _advance() internal;

    /// saving the year / month / day saves a call to BokkyPooBahsDateTimeLibrary._daysToDate, 
    /// at the expense of using a bit more storage (4x or 7x vs. just storing a timestamp)
    function _calculateNextPaymentTimestamp() private {
        // adjust for the days of month for payment days greater than 28 (since all months have at least 28 days)
        uint adjustedPaymentDay = DateTime.constrainToDaysInMonth(_nextPaymentYear, _nextPaymentMonth, _nextPaymentDay);

        // create the timestamp from year, month, and adjusted date
        uint date = DateTime.timestampFromDate(_nextPaymentYear, _nextPaymentMonth, adjustedPaymentDay);
        _nextPaymentTimestamp = DateTime.add(date, _secondsOffset);
    }

}