pragma solidity ^0.5.0;

interface IAuthorizedTokenTransferer {

    function transfer(address from, address to, address token, uint amount) external;

}