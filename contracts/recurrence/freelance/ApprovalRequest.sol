pragma solidity ^0.5.0;

import "../../lib/date/MockableCurrentTime.sol";
import "../../escrow/TokenEscrow.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract ApprovalRequest is Secondary, MockableCurrentTime {

    address private _requestedBy;
    uint private _requestedAmount;
    uint private _approvalDueBy;
    TokenEscrow private _escrow;

    event ApprovalGranted(address indexed grantedBy, address indexed to, uint forAmount);
    event ApprovalByDefault(address indexed to, uint approvalDueBy, uint defaultDate, uint forAmount);
    event RequestCancelled(address indexed cancelledBy);

    constructor (address requestedBy, uint requestedAmount, uint approvalDueBy, TokenEscrow escrow) public {
        _requestedBy = requestedBy;
        _requestedAmount = requestedAmount;
        _approvalDueBy = approvalDueBy;
        _escrow = escrow;
    }

    function approve() public /*onlyApprover*/ {
        _escrow.withdrawTo(_requestedBy, _requestedAmount);
        emit ApprovalGranted(msg.sender, _requestedBy, _requestedAmount);
    }

    function checkApprovalByDefault() public returns (bool approvedByDefault) {
        uint currentTime = _getCurrentTimeInUnixSeconds();
        if (currentTime > _approvalDueBy) {
            _escrow.withdrawTo(_requestedBy, _requestedAmount);
            emit ApprovalByDefault(_requestedBy, _approvalDueBy, currentTime, _requestedAmount);
            approvedByDefault = true;
        }
    }  

    function cancelRequest() public onlyPrimary {
        _escrow.transferPrimary(msg.sender);
        emit RequestCancelled(msg.sender);
        selfdestruct(address(uint160(msg.sender)));
    }

}