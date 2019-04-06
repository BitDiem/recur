pragma solidity ^0.5.0;

import "../accounts/Payable.sol";
import "../accounts/Receivable.sol";
import "../lib/date/MockableCurrentTime.sol";
import  "../dispute/TokenFundsDispute.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract TokenEscrow2 {

    IERC20 private _token;

    constructor (IERC20 token) public {
        _token = token;
    }

    function token() public view returns(IERC20) {
        return _token;
    }

    function escrow(address from, uint amount) public {
        _token.transferFrom(from, address(this), amount);
        //emit Escrowed(msg.sender, from, amount);
    }

    function withdrawTo(address to, uint amount) public {
        _token.transfer(to, amount);
        //emit Withdrawn(msg.sender, to, amount);
    }

}

contract ApprovalRequest is MockableCurrentTime {

    address _requestedBy;
    uint private _approvalRequestedAmount;
    uint private _approvalDueBy;
    TokenEscrow2 _escrow;

    event ApprovalGranted(address indexed grantedBy, uint forAmount);
    event ApprovalByDefault(uint approvalDueBy, uint defaultDate, uint forAmount);

    constructor (address requestedBy, uint approvalRequestedAmount, uint approvalDueBy, TokenEscrow2 escrow) public {

    }

    function approve() public {
        _escrow.withdrawTo(_requestedBy, _approvalRequestedAmount);
        emit ApprovalGranted(msg.sender, _approvalRequestedAmount);
    }

    function checkApprovalByDefault() public returns (bool approvedByDefault) {
        uint currentTime = _getCurrentTimeInUnixSeconds();
        if (currentTime > _approvalDueBy) {
            _escrow.withdrawTo(_requestedBy, _approvalRequestedAmount);
            emit ApprovalByDefault(_approvalDueBy, currentTime, _approvalRequestedAmount);
            approvedByDefault = true;
        }
    }  
}

/**
 * @title SubmitApproveWorkflow
 * @dev Represents a work agreement where one party must submit a request for approval from another party which may grant approval. 
 */
contract SubmitApproveWorkflow is
    Payable,
    Receivable,
    TokenEscrow2,
    MockableCurrentTime 
{

    //IERC20 private _token;
    uint private _periodAmount;
    uint private _maxAuthorizedPerPeriod;
    uint private _approvalTurnaroundTime;
    address private _agreedUponDisputeResolver;

    // member variables for approval
    uint private _approvalRequestedAmount;
    uint private _approvalDueBy;
    ApprovalRequest _currentApprovalRequest;

    event Escrowed(address indexed escrowedBy, address indexed escrowedTo, uint amount);
    event ApprovalRequested(ApprovalRequest indexed request, address indexed requestedBy, uint forAmount, uint approvalDueBy);
    //event ApprovalRequested(address indexed requestedBy, uint forAmount, uint approvalDueBy);
    //event ApprovalGranted(address indexed grantedBy, uint forAmount);
    //event ApprovalByDefault(uint approvalDueBy, uint defaultDate, uint forAmount);
    event DisputeCreated();

    constructor (
        address payor,
        address payee,
        IERC20 token,
        uint periodAmount,
        address agreedUponDisputeResolver
    )
        Payable(payor)
        Receivable(payee)
        TokenEscrow2(token)
        public 
    {
        //_token = token;
        _periodAmount = periodAmount;
        _agreedUponDisputeResolver = agreedUponDisputeResolver;
    }

    /**
     * @dev 
     */
    function escrowPeriodAmount() public onlyPayor {
        //_token.transferFrom(getPayor(), address(this), _periodAmount);
        escrow(getPayor(), _periodAmount);
        emit Escrowed(msg.sender, address(this), _periodAmount);
    }

    function submitForApproval(uint adjustedAmount) public onlyPayee {
        require(adjustedAmount <= _maxAuthorizedPerPeriod);
        _approvalRequestedAmount = adjustedAmount;
        _approvalDueBy = _getCurrentTimeInUnixSeconds() + _approvalTurnaroundTime;
        //emit ApprovalRequested(msg.sender, _approvalRequestedAmount, _approvalDueBy);
        ApprovalRequest request = new ApprovalRequest(
            getPayee(),
            _approvalRequestedAmount,
            _approvalDueBy,
            this
        );
        if (address(_currentApprovalRequest) != address(0)) {
            // reclaim the current approval request - basically cancelling it
        }
        _currentApprovalRequest = request;
        emit ApprovalRequested(request, msg.sender, _approvalRequestedAmount, _approvalDueBy);
    }

    /*function approve() public onlyPayor {
        //_token.transfer(getPayee(), _approvalRequestedAmount);
        withdrawTo(getPayee(), _approvalRequestedAmount);
        emit ApprovalGranted(msg.sender, _approvalRequestedAmount);
    }

    function checkApprovalByDefault() public returns (bool approvedByDefault) {
        uint currentTime = _getCurrentTimeInUnixSeconds();
        if (currentTime > _approvalDueBy) {
            //_token.transfer(getPayee(), _approvalRequestedAmount);
            withdrawTo(getPayee(), _approvalRequestedAmount);
            emit ApprovalByDefault(_approvalDueBy, currentTime, _approvalRequestedAmount);
            approvedByDefault = true;
        }
    }*/

    function dispute(IERC20 resolutionRewardToken, uint resolutionRewardAmount) public onlyPayee returns (TokenFundsDispute) {
        TokenFundsDispute disp = new TokenFundsDispute(
            token(),//_token, 
            _approvalRequestedAmount,
            resolutionRewardToken,
            resolutionRewardAmount,
            getPayor(),
            getPayee()
        );
        disp.addDisputeResolver(_agreedUponDisputeResolver);
        disp.renounceDisputeResolver();

        //_token.transfer(address(disp), _periodAmount);
        withdrawTo(address(disp), _periodAmount);
        resolutionRewardToken.transferFrom(msg.sender, address(disp), resolutionRewardAmount);
        emit DisputeCreated(); // TODO: define and fill out parameters
        return disp;
    }

}