pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title IAuthorizedTokenTransferer
 * @dev TODO: write
 */
interface IAuthorizedTokenTransferer {

    function transfer(address from, address to, IERC20 token, uint amount) external;

    function transferMax(address from, address to, IERC20 token, uint amount) external returns (uint, uint);

}