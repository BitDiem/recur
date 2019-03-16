pragma solidity ^0.5.0;

import "../frontend/SubscriptionFrontEnd.sol";
import "../accounts/AuthorizedTokenTransferer.sol";

contract PublisherFrontEnd {

    event PublisherCreated(
        SubscriptionFrontEnd publisher, 
        AuthorizedTokenTransferer authorizedTokenTransferer
    );

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
        SubscriptionFrontEnd frontEnd = new SubscriptionFrontEnd(authorizedTransferer);
        emit PublisherCreated(frontEnd, authorizedTransferer);
        return frontEnd;
    }

}