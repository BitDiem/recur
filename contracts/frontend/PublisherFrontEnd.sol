pragma solidity ^0.5.0;

import "../frontend/SubscriptionFrontEnd.sol";
import "../frontend/SubscriptionFactory.sol";
import "../accounts/AuthorizedTokenTransferer.sol";

contract PublisherFrontEnd {

    SubscriptionFactory private _subscriptionFactory;

    event PublisherCreated(SubscriptionFrontEnd publisher);
        
    constructor (SubscriptionFactory subscriptionFactory) public {
        _subscriptionFactory = subscriptionFactory;
    }

    function createPublisher() public returns (SubscriptionFrontEnd) {
        AuthorizedTokenTransferer authorizedTokenTransferer = new AuthorizedTokenTransferer();
        SubscriptionFrontEnd subscriptionFrontEnd = createPublisher(authorizedTokenTransferer);
        authorizedTokenTransferer.addWhitelistAdmin(address(subscriptionFrontEnd));
        authorizedTokenTransferer.renounceWhitelistAdmin();
        return subscriptionFrontEnd;
    }

    function createPublisher(
        AuthorizedTokenTransferer authorizedTransferer
    )
        public
        returns (SubscriptionFrontEnd)
    {
        SubscriptionFrontEnd frontEnd = new SubscriptionFrontEnd(
            _subscriptionFactory,
            authorizedTransferer
        );

        emit PublisherCreated(frontEnd);
        return frontEnd;
    }

}