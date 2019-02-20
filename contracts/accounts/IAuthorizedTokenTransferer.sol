pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

interface IAuthorizedTokenTransferer {

    function transfer(address from, address to, IERC20 token, uint amount) external;

}