pragma solidity ^0.5.0;

import "../../payment/roles/CreditAdminRole.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title PaymentCredit
 * @dev Encapsulates an amount of credit that can be debited against when making a payment
 */
contract PaymentCredit is CreditAdminRole {

    using SafeMath for uint;

    uint private _credit;

    event CreditChanged(uint creditTotal);

    function getCredit() public view returns (uint) {
        return _credit;
    }

    function addCredit(uint amount) public onlyCreditAdmin {
        require(amount > 0);
        _setCredit(_credit.add(amount));
    }

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