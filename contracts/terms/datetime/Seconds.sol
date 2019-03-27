pragma solidity ^0.5.0;

import "../../terms/PaymentObligation.sol";
import "../../lib/date/MockableCurrentTime.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Seconds
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in seconds, between due dates thereafter.  Payment amount is fixed 
 * (every payment is of the same amount).
 */
contract Seconds is PaymentObligation, MockableCurrentTime {

    using SafeMath for uint;

    uint private _nextPaymentDueTimestamp;
    uint private _amount;
    uint private _secondsIncrement;

    event PaymentDue(
        uint paymentDueDate, 
        uint amountDue, 
        uint elapsedIntervals, 
        uint nextPaymentDueDate
    );

    /**
     * @param amount Amount due at each due date timestamp.
     * @param nextPaymentDueTimestamp Due date timestamp for first payment due.
     * @param secondsIncrement The number of seconds between due dates.
     */
    constructor(
        uint amount,
        uint nextPaymentDueTimestamp,
        uint secondsIncrement
    )
        public
    {
        require(amount > 0);
        require(secondsIncrement > 0);

        _amount = amount;
        _nextPaymentDueTimestamp = nextPaymentDueTimestamp;
        _secondsIncrement = secondsIncrement;

        emit PaymentDue(0, 0, 0, _nextPaymentDueTimestamp);
    }

    /// Calculates the number of elapsed intervals between "now" and last payment due date, then uses that to
    /// determine the amount due and next due date.
    function _calculateOutstandingAmount() internal returns (uint amountDue) {
        uint currentTime = _getCurrentTimeInUnixSeconds();
        if (currentTime < _nextPaymentDueTimestamp)
            return 0;

        uint elapsedTime = currentTime - _nextPaymentDueTimestamp + _secondsIncrement;
        uint elapsedIntervals = elapsedTime / _secondsIncrement;
        amountDue = _amount * elapsedIntervals;
        uint offset = elapsedIntervals * _secondsIncrement;
        _nextPaymentDueTimestamp = _nextPaymentDueTimestamp.add(offset);   
        uint currentPaymentDueAt = _nextPaymentDueTimestamp - _secondsIncrement; // no over/underflow check here due to prev line

        emit PaymentDue(currentPaymentDueAt, amountDue, elapsedIntervals, _nextPaymentDueTimestamp);
    }

}