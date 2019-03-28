pragma solidity ^0.5.0;

import "../../payment/roles/CreditAdminRole.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title PaymentCredit
 * @dev Stores a credit value that can be debited against when making a payment.  
 * Approved callers can add or remove to the credit value.  Credit value can also be 
 * set directly in child contracts.  Emits an event on credit value change.
 */
contract PaymentCredit is CreditAdminRole {

    using SafeMath for uint;

    uint private _credit;

    event CreditChanged(uint creditTotal);

    function getCredit() public view returns (uint) {
        return _credit;
    }

    /**
     * @dev Add credit.  Only callable by approved addresses.
     * @param amount The amount of credit to add to the existing credit value.
     */
    function addCredit(uint amount) public onlyCreditAdmin {
        require(amount > 0);
        _setCredit(_credit.add(amount));
    }

    /**
     * @dev Remove credit.  Only callable by approved addresses.
     * @param amount The amount of credit to deduct from the existing credit value.
     */
    function removeCredit(uint amount) public onlyCreditAdmin {
        require(amount > 0);
        _setCredit(_credit.sub(amount));
    }

    function _setCredit(uint credit) internal {
        if(_credit == credit) return;
        _credit = credit;
        emit CreditChanged(_credit);
    }

}