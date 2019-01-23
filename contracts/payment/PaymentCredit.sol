pragma solidity ^0.5.0;

/**
 * @title PaymentProcessor
 * @dev Encapsulates an amount of credit that can be debited against when making a payment
 */
contract PaymentCredit {

    uint _credit;

    event CreditChanged(uint creditTotal);

    function getCredit() public view returns (uint) {
        return _credit;
    }

    function _setCredit(uint credit) internal {
        _credit = credit;
        emit CreditChanged(_credit);
    }

}