pragma solidity ^0.5.0;

interface ISubscriptionPaymentTerms {

    function currentAmountDue() external returns (uint);

    function markAsPaid(uint amount) external;

}