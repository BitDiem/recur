pragma solidity ^0.5.0;

import "./payment/PaymentProcessor.sol";
import "./terms/IPaymentTerms.sol";
import "./accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract StandardSubscription is PaymentProcessor {
    
    using SafeMath for uint;

    IPaymentTerms private _paymentTerms;

    event SubscriptionEnded(address endedBy);

    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        address token,
        IPaymentTerms paymentTerms
    ) 
        PaymentProcessor(payor, payee, authorizedTransferer, token)
        public 
    {
        _paymentTerms = paymentTerms;
    }

    function payCurrentAmountDue() public {
        uint newAmountDue = _paymentTerms.currentAmountDue();
        (uint amountPaid,) = pay(newAmountDue);
        _paymentTerms.markAsPaid(amountPaid);
    }

    function endSubscription() public {
        require(getPayor() == msg.sender || getPayee() == msg.sender);
        emit SubscriptionEnded(msg.sender);
    }

}