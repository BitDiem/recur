pragma solidity ^0.5.0;

import "./ApprovalRequest.sol";
import "../../accounts/Payable.sol";
import "../../accounts/Receivable.sol";
import "../../dispute/TokenFundsDispute.sol";
import "../../escrow/TokenEscrow.sol";
import "../../lib/date/MockableCurrentTime.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title SubmitApproveWorkflow
 * @dev Represents a work agreement where one party must submit a request for approval from another party which may grant approval. 
 */
contract SubmitApproveWorkflow is Payable, Receivable, MockableCurrentTime {

    /// read-only
    IERC20 private _token;
    uint private _periodAmount;
    uint private _maxAuthorizedPerPeriod;
    uint private _approvalTurnaroundTime;
    address private _agreedUponDisputeResolver;
    TokenEscrow private _escrow;

    /// mutable
    ApprovalRequest private _currentApprovalRequest;
    uint private _approvalRequestedAmount;

    event Escrowed(IERC20 indexed token, uint amount);
    event ApprovalRequested(ApprovalRequest indexed request, address indexed requestedBy, uint forAmount, uint approvalDueBy);
    event DisputeCreated(TokenFundsDispute indexed dispute);

    constructor (
        address payor,
        address payee,
        IERC20 token,
        uint periodAmount,
        address agreedUponDisputeResolver
    )
        Payable(payor)
        Receivable(payee)
        public 
    {
        _token = token;
        _periodAmount = periodAmount;
        _agreedUponDisputeResolver = agreedUponDisputeResolver;
        _escrow = new TokenEscrow(token);
    }

    /**
     * @dev 
     */
    function escrowPeriodAmount() public onlyPayor {
        _escrow.deposit(getPayor(), _periodAmount);
        emit Escrowed(_token, _periodAmount);
    }

    function submitForApproval(uint adjustedAmount) public onlyPayee {
        require(adjustedAmount <= _maxAuthorizedPerPeriod);
        _approvalRequestedAmount = adjustedAmount;
        uint approvalDueBy = _getCurrentTimeInUnixSeconds() + _approvalTurnaroundTime;

        ApprovalRequest request = new ApprovalRequest(
            getPayee(),
            _approvalRequestedAmount,
            approvalDueBy,
            _escrow
        );

        // cancel the current approval request
        if (address(_currentApprovalRequest) != address(0)) {
            _currentApprovalRequest.cancelRequest();
        }
        _currentApprovalRequest = request;
        _escrow.transferPrimary(address(_currentApprovalRequest));

        emit ApprovalRequested(request, msg.sender, _approvalRequestedAmount, approvalDueBy);
    }

    function dispute(
        IERC20 resolutionRewardToken, 
        uint resolutionRewardAmount
    ) 
        public
        onlyPayee
        returns (TokenFundsDispute _dispute)
    {
        require(address(_currentApprovalRequest) != address(0));
        _currentApprovalRequest.cancelRequest();

        _dispute = new TokenFundsDispute(
            _token, 
            _approvalRequestedAmount,
            resolutionRewardToken,
            resolutionRewardAmount,
            getPayor(),
            getPayee()
        );
        _dispute.addDisputeResolver(_agreedUponDisputeResolver);
        _dispute.renounceDisputeResolver();

        _escrow.withdrawTo(address(_dispute), _periodAmount);

        resolutionRewardToken.transferFrom(msg.sender, address(_dispute), resolutionRewardAmount);
        emit DisputeCreated(_dispute); // TODO: define and fill out parameters
        end();
    }

    function end() public {
        require(isPayor() || isPayee());
        address payable balanceRecipient = address(uint160(getPayor()));
        // destroy token escrow
        selfdestruct(balanceRecipient);
    }
}