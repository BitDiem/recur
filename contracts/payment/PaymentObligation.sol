pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

/**
 * @title PaymentObligation
 * @dev Base contract for creating contracts that determine when an arbitrary amount is due.
 */
contract PaymentObligation is Secondary {

    event PaymentObligationEnded(address endedBy);

    /**
     * @dev Calculates the full amount due.
     * NOTE: this call is expected to change the state of the child contract, and as such the returned value 
     * needs to be "consumed" otherwise it is lost.  Check the code in Subscription.sol to see that the value 
     * from this function call gets added to the outstanding debt.
     * @return A uint value of the full amount due.
     */
    function currentAmountDue() public onlyPrimary returns (uint) {
        return _calculateOutstandingAmount();
    }

    function destroy(address payable balanceRecipient) public onlyPrimary {
        emit PaymentObligationEnded(msg.sender);
        selfdestruct(balanceRecipient);
    }

    function _calculateOutstandingAmount() internal returns (uint);
    
}