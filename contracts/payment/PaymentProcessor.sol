pragma solidity ^0.5.4;

import "../accounts/Payable.sol";
import "../accounts/Receivable.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";
import "../payment/PayFromCredit.sol";
import "../payment/PayFromContract.sol";
import "../payment/PayFromAddress.sol";
//import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title PaymentProcessor
 * @dev Encapsulates a relationship between a paying party, a payment recipient, which token 
 * is used as payment, and through what authorized transferer.  Allows the paying party to debit 
 * against a virtual credit, against a token balance of this contract's address, and finally against 
 * the paying party's address.
 */
contract PaymentProcessor is 
    Payable, 
    Receivable, 
    PayFromCredit, 
    PayFromContract,
    PayFromAddress
{

    //using SafeMath for uint;

    IAuthorizedTokenTransferer private _authorizedTransferer;
    IERC20 private _token;

    event PaymentProcessed(uint totalPaid, uint remainder);

    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        IERC20 token
    ) 
        Payable(payor)
        Receivable(payee)
        internal
    {
        _authorizedTransferer = authorizedTransferer;
        _token = token;
    }

    function pay(uint paymentAmount) internal returns (uint remainder) {
        remainder = paymentAmount;
        remainder = _payFromCredit(remainder);
        remainder = _payFromTokenBalance(remainder);
        remainder = _payFromAuthorizedTransferer(remainder);

        uint amountPaid = paymentAmount - remainder;

        emit PaymentProcessed(amountPaid, remainder);
        
        return remainder;
    }

    function _payFromTokenBalance(uint amount) private returns (uint) {
        return _payFromTokenBalance(getPayee(), _token, amount);
    }

    function _payFromAuthorizedTransferer(uint amount) private returns (uint) {
        return _payFromAddress(getPayor(), getPayee(), _token, amount, _authorizedTransferer);
    }

}