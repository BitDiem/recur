pragma solidity ^0.5.0;

import "../subscription/StandardSubscription.sol";
import "../payment/PaymentObligation.sol";
import "../accounts/AuthorizedTokenTransferer.sol";
import "../lib/factory/SubscriptionFactory.sol";
import "../lib/factory/MonthlyTermsFactory.sol";
import "../lib/factory/MonthsTermsFactory.sol";
import "../lib/factory/YearlyTermsFactory.sol";
import "../lib/factory/FixedIntervalTermsFactory.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract SubscriptionFrontEnd {

    event SubscriptionCreated(
        StandardSubscription subscriptionAddress,
        PaymentObligation paymentTerms,
        IERC20 paymentToken,
        address payor, 
        address payee
    );

    AuthorizedTokenTransferer private _tokenTransferer;

    constructor (AuthorizedTokenTransferer tokenTransferer) public {
        _tokenTransferer = tokenTransferer;
    }

    function getTokenTransferer() public view returns (AuthorizedTokenTransferer) {
        return _tokenTransferer;
    }

    function createMonthlySubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = MonthlyTermsFactory.create(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second
        );
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createMonthsSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint monthIncrement
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = MonthsTermsFactory.create(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second,
            monthIncrement
        );
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createYearlySubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = YearlyTermsFactory.create(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second
        );
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createFixedIntervalSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint interval,
        uint delay
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = FixedIntervalTermsFactory.create(paymentAmount, interval, delay);
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createSubscription(
        address payee,
        IERC20 paymentToken, 
        PaymentObligation paymentTerms
    )
        public
        returns (StandardSubscription)
    {
        address payor = msg.sender;

        StandardSubscription subscription = SubscriptionFactory.create(
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

        emit SubscriptionCreated(subscription, paymentTerms, paymentToken, payor, payee);

        return subscription;
    }

    function _createSubscription2(
        address payee,
        IERC20 paymentToken,
        PaymentObligation paymentTerms
    )
        private
        returns (StandardSubscription)
    {
        StandardSubscription subscription = createSubscription(payee, paymentToken, paymentTerms);
        paymentTerms.transferPrimary(address(subscription));
        return subscription;
    }

}