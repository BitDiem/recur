pragma solidity ^0.5.0;

import "./IAuthorizedTokenTransferer.sol";
import "./Payable.sol";
import "./Receivable.sol";
import "./Balance.sol";
import "./Balanceable.sol";
import "./Creditable.sol";
import "./SubscriptionRecurringPaymentTerms.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract ComposedSubscription is Creditable, Balanceable, SubscriptionRecurringPaymentTerms {
    
    using SafeMath for uint;

    Balance _debt;

    event PaymentMade(uint paymentAmount, uint numberOfPayments);
    event SubscriptionEnded(address endedBy);

    constructor (
        IAuthorizedTokenTransferer authorizedTransferer,
        address payor, 
        address payee, 
        address token, 
        uint amount, 
        uint timeInterval,
        uint delay
    ) 
        Creditable(payor, payee, authorizedTransferer, token)
        //Balanceable(payor, payee, authorizedTransferer, token)
        SubscriptionRecurringPaymentTerms(amount, timeInterval, delay)
        public 
    {
        _debt = new Balance();
    }

    function pay() public {
        toCurrentTimeSafe();
        uint paymentAmount = outstandingAmount();
        process(paymentAmount);

        uint remainder = paymentAmount + _debt.get();
        remainder = payFromCredit(remainder);
        remainder = payFromBalance(remainder);
        remainder = payFromAuthorizedTransferer(remainder);

        uint amountPaid = paymentAmount - remainder;

        _debt.set(remainder);
        emit PaymentMade(amountPaid, 0);


        /*uint currentBlock = block.number;
        uint elapsedBlocks = currentBlock - _lastPaymentBlock;
        uint div = elapsedBlocks / _interval;
        uint mod = elapsedBlocks % _interval;
        uint paymentAmount = _amount * div;

        require (div > 0);

        uint remainder = paymentAmount + _debt.get();
        remainder = payFromCredit(remainder);
        remainder = payFromBalance(remainder);
        remainder = payFromAuthorizedTransferer(remainder);

        uint amountPaid = paymentAmount - remainder;
        _debt.set(remainder);

        _lastPaymentBlock = currentBlock - mod;

        emit PaymentMade(amountPaid, div);*/
    }

    function endSubscription() public {
        require(getPayor() == msg.sender || getPayee() == msg.sender);
        emit SubscriptionEnded(msg.sender);
        //selfdestruct(this);
    }
 
    function payFromAuthorizedTransferer(
        uint amount
    )
        internal
        returns (uint) 
    {
        if (amount == 0)
            return amount;

        IERC20 tokenContract = IERC20(token());

        // check how much the transferer is authorized to send on behalf of the payor
        uint authorizedAmount = tokenContract.allowance(getPayor(), address(authorizedTransferer()));
        uint availableBalance = tokenContract.balanceOf(getPayor());
        uint amountToPay = Math.min(amount, Math.min(authorizedAmount, availableBalance));

        authorizedTransferer().transfer(getPayor(), getPayee(), token(), amountToPay);

        uint remainder = amount - amountToPay;
        return remainder;
    }

}


    
/*

function _calculateIntervalsViaBlockNumber() private view returns (uint) {
        uint currentBlock = block.number;
        uint elapsedBlocks = currentBlock - _lastPaymentBlock;
        uint elapsedBlockPeriods = elapsedBlocks / _interval;

        return elapsedBlockPeriods;
    }

    function _calculateIntervalstViaTimestamp() private view returns (uint) {
        uint currentTime = now;
        uint elapsedTime = currentTime - _lastPaymentTime;
        uint elapsedTimePeriods = elapsedTime / _interval;

        return elapsedTimePeriods;
    }

Two types of refund:

Credit (a virtual transfer of money to subscriber)
Fund (real and immediate transfer of actual tokens)

Calculation when paying:

remainder = amount;
remainder = payFromCredit(remainder);
remainder = payFromBalance(remainder);
remainder = payFromAuhorizedTransferer(remainder);

require(remainder == 0);

Or:
return remainder;*/



/*contract FixedRateSubscription is Creditable, Balanceable {
    
    IAuthorizedTokenTransferer _authorizedTransferer;
    address _payor; 
    address _pendingPayor;
    address _payee; 
    address _token;
    uint _amount;
    uint _interval;             // interval in blocks
    uint _timeInterval;         // interval as unix milliseconds
    uint _lastPaymentBlock;     // if using block based intervals
    uint _lastPaymentTime;      // if using time based intervals - less secure?  Exploitable?  open question
    uint _delay;                // use case: "first 30 days free"

    event PayorTransferRequested(address indexed requestedPayor);       // change verbiage from "transfer" to "change"?
    event PayorTransferApproved(address indexed approvedPayor);
    event PayeeTransferred(address indexed payee);
    event Payment(uint paymentAmount, uint numberOfPayments);
    event SubscriptionEnded(address endedBy);

    constructor (
        IAuthorizedTokenTransferer authorizedTransferer,
        address payor, 
        address payee, 
        address token, 
        uint amount, 
        uint interval
    ) 
        public 
    {
        _authorizedTransferer = authorizedTransferer;
        _payor = payor;
        _payee = payee;
        _token = token;
        _amount = amount;
        _interval = interval;
        _lastPaymentBlock = block.number;
        _lastPaymentTime = now;
    }

    function transferPayor(address pendingPayor) public {
        require(_payor == msg.sender);
        _pendingPayor = pendingPayor;
        emit PayorTransferRequested(pendingPayor);
    }

    function approveTransferPayor() public {
        require(_pendingPayor == msg.sender);
        _payor = _pendingPayor;
        delete _pendingPayor;
        emit PayorTransferApproved(_payor);
    }

    function transferPayee(address payee) public {
        require(_payee == msg.sender);
        _payee = payee;
        emit PayeeTransferred(_payee);
    }

    function pay() public {
        uint currentBlock = block.number;
        uint currentTime = now;

        uint elapsedBlocks = currentBlock - _lastPaymentBlock;
        uint elapsedTime = currentTime - _lastPaymentTime;

        uint elapsedBlockPeriods = elapsedBlocks / _interval;
        uint elapsedTimePeriods = elapsedTime / _interval;

        uint paymentAmount = _amount * elapsedBlockPeriods;

        _authorizedTransferer.transfer(_token, _payor, _payee, paymentAmount);

        emit Payment(paymentAmount, elapsedBlockPeriods);
    }

    function endSubscription() public {
        require(_payor == msg.sender || _payee == msg.sender);
        emit SubscriptionEnded(msg.sender);
        //selfdestruct(this);
    }
}*/