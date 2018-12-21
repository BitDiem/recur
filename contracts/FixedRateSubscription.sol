pragma solidity ^0.4.24;

import "./IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract FixedRateSubscription {
    
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
        selfdestruct(this);
    }
}

contract Payable {
    address _payor;
    address _pendingPayor;

    event PayorTransferRequested(address indexed requestedPayor);       // change verbiage from "transfer" to "change"?
    event PayorTransferApproved(address indexed approvedPayor);

    constructor (address payor) public {
        _payor = payor;
    }

    modifier onlyPayor() {
        require(_payor == msg.sender);
        _;
    }

    modifier onlyPendingPayor() {
        require(_pendingPayor == msg.sender);
        _;
    }

    function transferPayor(address pendingPayor) public onlyPayor {
        require(_pendingPayor != pendingPayor);
        _pendingPayor = pendingPayor;
        emit PayorTransferRequested(pendingPayor);
    }

    function approveTransferPayor() public onlyPendingPayor {
        _payor = _pendingPayor;
        delete _pendingPayor;
        emit PayorTransferApproved(_payor);
    }
}

contract Receivable {
    address _payee;

    event PayeeTransferred(address indexed payee);

    constructor (address payee) public {
        _payee = payee;
    }

    modifier onlyPayee() {
        require(_payee == msg.sender);
        _;
    }

    function transferPayee(address payee) public onlyPayee {
        require(_payee != payee);
        _payee = payee;
        emit PayeeTransferred(_payee);  
    }
}

contract ComposedSubscription is Payable, Receivable {
    
    using SafeMath for uint;

    IAuthorizedTokenTransferer _authorizedTransferer;
    address _token;
    uint _amount;
    uint _interval;             // interval in blocks
    uint _timeInterval;         // interval as unix milliseconds
    uint _lastPaymentBlock;     // if using block based intervals
    uint _lastPaymentTime;      // if using time based intervals - less secure?  Exploitable?  open question
    //uint _delay;                // use case: "first 30 days free"

    uint _balance;

    event Payment(uint paymentAmount, uint numberOfPayments);
    event SubscriptionEnded(address endedBy);
    event BalanceSent(address to, uint amount);

    constructor (
        IAuthorizedTokenTransferer authorizedTransferer,
        address payor, 
        address payee, 
        address token, 
        uint amount, 
        uint interval,
        uint delay
    ) 
        Payable(payor)
        Receivable(payee)
        public 
    {
        _authorizedTransferer = authorizedTransferer;
        _token = token;
        _amount = amount;
        _interval = interval;
        _lastPaymentBlock = block.number + delay;
        _lastPaymentTime = now + delay;
    }

    function pay() public {
        uint currentBlock = block.number;
        uint elapsedBlocks = currentBlock - _lastPaymentBlock;
        uint div = elapsedBlocks / _interval;
        uint mod = elapsedBlocks % _interval;
        uint paymentAmount = _amount * div;

        require (div > 0);

        uint adjustedPaymentAmount = paymentAmount - _balance;
        if (_balance > 0) {
            _sendBalance(_payee, _balance);          
        }
        if (adjustedPaymentAmount > 0) {
            _authorizedTransferer.transfer(_token, _payor, _payee, adjustedPaymentAmount);
        }

        _lastPaymentBlock = currentBlock - mod;

        emit Payment(paymentAmount, div);
    }

    function endSubscription() public {
        require(_payor == msg.sender || _payee == msg.sender);
        emit SubscriptionEnded(msg.sender);
        selfdestruct(this);
    }

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

    function credit(uint amount) public {
        require(amount > 0);
        _balance = _balance.add(amount);
        _authorizedTransferer.transfer(_token, msg.sender, address(this), amount);
    }

    function withdraw(uint amount) public onlyPayor {
        require(amount > 0);
        _balance = _balance.sub(amount);
        _sendBalance(_payor, amount);
    }

    function _sendBalance(address to, uint amount) private {
        IERC20 tokenContract = IERC20(_token);
        tokenContract.transferFrom(address(this), to, amount);
        emit BalanceSent(to, amount);
    }
}