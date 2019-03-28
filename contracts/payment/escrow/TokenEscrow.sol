pragma solidity ^0.5.0;

import "../../payment/roles/TokenWithdrawerRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenEscrow
 * @dev Allows withdrawal of any ERC20 tokens sent to this contract.  
 * The call to withdraw tokens is restricted to approved addresses only.
 * Emits an event on successful token withdrawal.
 */
contract TokenEscrow is TokenWithdrawerRole {

    event TokenWithdrawn(address indexed withdrawer, IERC20 indexed token, uint amount);

    /**
     * @dev Allows an approved address to withdraw a non-zero amount of any erc20 token held in this contract.  
     * Tokens are transferred to the caller's address.
     * @param token The IERC20 interface of the ERC20 token to withdraw.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawToken(IERC20 token, uint amount) public onlyTokenWithdrawer {
        require(amount > 0);
        address to = msg.sender;
        token.transfer(to, amount);
        emit TokenWithdrawn(to, token, amount);
    }

}