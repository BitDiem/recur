pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract PaymentObligation is Secondary {

    event PaymentObligationEnded(address endedBy);

    function currentAmountDue() public onlyPrimary returns (uint) {
        return _calculateOutstandingAmount();
    }

    function destroy(address payable balanceRecipient) public onlyPrimary {
        emit PaymentObligationEnded(msg.sender);
        selfdestruct(balanceRecipient);
    }

    function _calculateOutstandingAmount() internal returns (uint);
    
}