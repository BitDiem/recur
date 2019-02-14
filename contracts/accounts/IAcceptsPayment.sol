pragma solidity ^0.5.0;

/**
 * @title IAcceptsPayment
 * @dev TODO: write
 */
interface IAcceptsPayment {

    function receiveToken(address from, address token, uint amount) external;

}