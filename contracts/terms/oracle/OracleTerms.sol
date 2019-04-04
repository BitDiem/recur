pragma solidity ^0.5.0;

import "./OracleRole.sol";
import "../../terms/PaymentObligation.sol";
import "../../lib/date/MockableCurrentTime.sol";

/**
 * @title OracleTerms
 * @dev Allows an authorized oracle to push next payment amount and due date.
 */
contract OracleTerms is PaymentObligation, MockableCurrentTime, OracleRole {

    uint private _nextPaymentTimestamp;
    uint private _nextAmountDue;

    event PaymentDue(uint paymentDueDate, uint amount);
    event NextPaymentDueOn(uint nextPaymentTimestamp, uint nextAmountDue);

    function setNextPaymentDue(uint nextPaymentTimestamp, uint nextAmountDue) public onlyOracle {
        // don't bother to check for timestamp or amount > 0 ?
        _nextPaymentTimestamp = nextPaymentTimestamp;
        _nextAmountDue = nextAmountDue;
        emit NextPaymentDueOn(nextPaymentTimestamp, nextAmountDue);
    }

    function _calculateOutstandingAmount() internal returns (uint) {
        if (_getCurrentTimeInUnixSeconds() < _nextPaymentTimestamp)
            return 0;

        emit PaymentDue(_nextPaymentTimestamp, _nextAmountDue);
        return _nextAmountDue;
    }

}