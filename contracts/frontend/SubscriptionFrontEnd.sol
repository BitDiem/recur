pragma solidity ^0.5.0;

import "../accounts/AuthorizedTokenTransferer.sol";
import "../accounts/SinglePayee.sol";
import "../terms/RecurringPaymentTerms.sol";
import "../StandardSubscription.sol";

contract SubscriptionFrontEnd is AuthorizedTokenTransferer {

    mapping (address => bool) activeSubs;
    event SubscriptionCreated(address subscriptionAddress, address payor, address payee);

    function createFixedRateSubscription(
        address payee,
        address paymentToken, 
        uint paymentAmount,
        uint interval,
        uint delay
    )
        public
        returns (address)
    {
        address payor = msg.sender;
        IAuthorizedTokenTransferer authorizedTokenTransferer = this;

        RecurringPaymentTerms paymentTerms = new RecurringPaymentTerms(
            paymentAmount, 
            interval, 
            delay
        );

        SinglePayee singlePayee = new SinglePayee(payee, authorizedTokenTransferer);

        StandardSubscription sub = new StandardSubscription(
            payor,
            address(authorizedTokenTransferer), 
            paymentToken, 
            paymentTerms,
            singlePayee);

        address subAddress = address(sub);

        _whitelistedCallers[subAddress] = true;

        emit SubscriptionCreated(subAddress, payor, payee);

        return subAddress;
    }

}