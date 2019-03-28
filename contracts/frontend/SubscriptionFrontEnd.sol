pragma solidity ^0.5.0;

import "../subscription/StandardSubscription.sol";
import "../terms/PaymentObligation.sol";
import "../accounts/AuthorizedTokenTransferer.sol";
import "../lib/factory/SubscriptionFactory.sol";
import "../lib/factory/MonthlyTermsFactory.sol";
import "../lib/factory/MonthsTermsFactory.sol";
import "../lib/factory/YearlyTermsFactory.sol";
import "../lib/factory/SecondsTermsFactory.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title SubscriptionFrontEnd
 * @dev TODO: write
 */
contract SubscriptionFrontEnd {

    AuthorizedTokenTransferer private _tokenTransferer;

    event SubscriptionCreated(
        StandardSubscription subscriptionAddress,
        PaymentObligation paymentTerms,
        IERC20 paymentToken,
        address payor, 
        address payee
    );

    constructor (AuthorizedTokenTransferer tokenTransferer) public {
        _tokenTransferer = tokenTransferer;
    }

    function getTokenTransferer() public view returns (AuthorizedTokenTransferer) {
        return _tokenTransferer;
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

    function createMonthsIntervalSubscription(
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

    function createDaysIntervalSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint daysIncrement
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = SecondsTermsFactory.createDays(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second,
            daysIncrement
        );
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createHoursIntervalSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint hoursIncrement
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = SecondsTermsFactory.createHours(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second,
            hoursIncrement
        );
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createMinutesIntervalSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint minutesIncrement
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = SecondsTermsFactory.createMinutes(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second,
            minutesIncrement
        );
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createSecondsIntervalSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint secondsIncrement
    )
        external
        returns (StandardSubscription)
    {
        PaymentObligation paymentTerms = SecondsTermsFactory.createSeconds(
            paymentAmount, 
            year, 
            month, 
            day,
            hour,
            minute,
            second,
            secondsIncrement
        );
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