pragma solidity ^0.5.0;

import "../accounts/AuthorizedTokenTransferer.sol";
import "../terms/RecurringPaymentTerms.sol";
import "../StandardSubscription.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract SubscriptionFrontEnd {

    AuthorizedTokenTransferer private _tokenTransferer;

    constructor (AuthorizedTokenTransferer tokenTransferer) public {
        if (address(tokenTransferer) == address(0)) {
            _tokenTransferer = new AuthorizedTokenTransferer();
        } else {
            _tokenTransferer = tokenTransferer;
        }
    }

    event SubscriptionCreated(address subscriptionAddress, address payor, address payee);

    function getTokenTransferer() public view returns (AuthorizedTokenTransferer) {
        return _tokenTransferer;
    }

    function createFixedPeriodSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint interval,
        uint delay
    )
        public
        returns (address)
    {
        RecurringPaymentTerms paymentTerms = new RecurringPaymentTerms(
            paymentAmount, 
            interval, 
            delay
        );

        address subscriptionAddress = createSubscription(payee, paymentToken, paymentTerms);
        paymentTerms.transferPrimary(subscriptionAddress);

        return subscriptionAddress;
    }

    function createSubscription(
        address payee,
        IERC20 paymentToken, 
        PaymentObligation paymentTerms
    )
        public
        returns (address)
    {
        address payor = msg.sender;

        StandardSubscription subscription = new StandardSubscription(
            payor,
            payee,
            _tokenTransferer, 
            paymentToken, 
            paymentTerms);

        subscription.addCreditAdmin(payee);
        subscription.renounceCreditAdmin();

        subscription.addTokenWithdrawer(payor);
        subscription.renounceTokenWithdrawer();

        address subscriptionAddress = address(subscription);
        _tokenTransferer.addWhitelisted(subscriptionAddress);

        emit SubscriptionCreated(subscriptionAddress, payor, payee);

        return subscriptionAddress;
    }

}