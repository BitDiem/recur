pragma solidity ^0.5.0;

import "./payment/PaymentProcessor.sol";
import "./payment/IPaymentObligation.sol";
import "./accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract StandardSubscription is PaymentProcessor {
    
    using SafeMath for uint;

    IPaymentObligation private _paymentObligation;

    event SubscriptionEnded(address endedBy);

    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        address token,
        IPaymentObligation paymentObligation
    ) 
        PaymentProcessor(payor, payee, authorizedTransferer, token)
        public 
    {
        _paymentObligation = paymentObligation;
    }

    function payCurrentAmountDue() public {
        uint amountDue = _paymentObligation.currentAmountDue();
        (uint amountPaid,) = pay(amountDue);
        _paymentObligation.markAsPaid(amountPaid);
    }

    function endSubscription() public {
        require(getPayor() == msg.sender || getPayee() == msg.sender);
        emit SubscriptionEnded(msg.sender);
    }

}