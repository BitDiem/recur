pragma solidity ^0.5.4;

import "../../payment/roles/TokenWithdrawerRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenEscrow
 * @dev Allows retrieval of any ERC20 tokens sent to the contract
 */
contract TokenEscrow is TokenWithdrawerRole {

    event TokenWithdrawn(address indexed withdrawer, IERC20 indexed token, uint amount);

    /**
     * @dev Allows allows an approved token withdrawer address to withdraw any erc20 token held in this contract.
     * @param token The address of the ERC20 token to withdraw
     * @param amount The balance amount to withdraw
     */
    function withdrawToken(IERC20 token, uint amount) public onlyTokenWithdrawer {
        require(amount > 0);
        address to = msg.sender;
        token.transfer(to, amount);
        emit TokenWithdrawn(to, token, amount);
    }

}