pragma solidity ^0.4.24;

interface IAuthorizedTokenTransferer {

    function transfer(address token, address from, address to, uint amount) external;

}