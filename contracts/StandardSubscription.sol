pragma solidity ^0.5.0;

import "./payment/PaymentProcessor.sol";
import "./payment/IPaymentObligation.sol";
import "./accounts/IAuthorizedTokenTransferer.sol";

contract StandardSubscription is PaymentProcessor {
    
    IPaymentObligation private _paymentObligation;

    event SubscriptionEnded(address endedBy);

    constructor (
        address payor,
        address transferer,
        address token,
        IPaymentObligation paymentObligation,
        IAcceptsPayment acceptsPayment
    ) 
        PaymentProcessor(payor, transferer, token, acceptsPayment)
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
        require(getPayor() == msg.sender /*||  getPayee() == msg.sender */);
        emit SubscriptionEnded(msg.sender);
    }

}

/*contract SafeSubscription is StandardSubscription, IAuthorizedTokenTransferer {

    constructor (
        address payee,
        address token,
        IPaymentObligation paymentObligation
    ) 
        StandardSubscription(msg.sender, payee, this, token, paymentObligation)
        public 
    {
    }

    function transfer(
        address from, 
        address to, 
        address token,
        uint amount
    ) 
        public
    {
        require (msg.sender == address(this));
        IERC20 tokenContract = IERC20(token);
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
    }

}*/