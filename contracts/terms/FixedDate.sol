pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/date/DateTime.sol";
import "../lib/date/MockableCurrentTime.sol";

/**
 * @title FixedDate
 * @dev Base contract for specifying an exact datetime that payment is due on.  
 * Year and month of next payment can be manipulated by child contracts.
 * Contract stores the year, month, day and total seconds offset, in addition to a timestamp of the payment due date.
 * Justification: saves a call to BokkyPooBahsDateTimeLibrary._daysToDate, at the expense of using a bit more 
 * storage (4 additional uint's vs. just storing the payment due date timestamp).
 * 
 * NOTE: For this contract as well as those deriving from it, specifying a "day" greater than 31 will ensure 
 * that payment is due on the last day of the month, regardless of how many days are in that month.
 */
contract FixedDate is PaymentObligation, MockableCurrentTime {

    uint internal _year;
    uint internal _month;

    uint private _day;
    uint private _secondsOffset;
    uint private _nextPaymentTimestamp;
    uint private _amount;

    event PaymentDue(uint paymentDueDate, uint amount);

    constructor(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second
    )
        public
    {
        require(amount > 0);
        require(DateTime.isValidYearAndMonth(year, month));
        require(day > 0);
        require(DateTime.isValidTime(hour, minute, second));

        _amount = amount;
        _year = year;
        _month = month;
        _day = day;

        _secondsOffset = DateTime.totalSeconds(hour, minute, second);
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
    /// at the expense of using a bit more storage (4 more uints vs. just storing a timestamp)
    function _calculateNextPaymentTimestamp() private {
        // adjust for the days of month for payment days greater than 28 (since all months have at least 28 days)
        uint adjustedPaymentDay = DateTime.constrainToDaysInMonth(_year, _month, _day);

        // create the timestamp from year, month, and adjusted date.  Then add the total seconds offset to get exacte due date
        uint date = DateTime.timestampFromDate(_year, _month, adjustedPaymentDay);
        _nextPaymentTimestamp = DateTime.add(date, _secondsOffset);
    }

}