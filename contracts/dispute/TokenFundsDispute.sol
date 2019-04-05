pragma solidity ^0.5.0;

import "./DisputeResolverRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenFundsDispute
 * @dev Represents a dispute between two parties over some amount of an ERC20 token.  An authorized dispute resolver can 
 * judge in favor of one party over another, or split an amount between the two parties.  Dispute resolution results in 
 * an amount of reward ERC20 tokens given to the dispute resolver, as incentive for resolving the dispute. 
 */
contract TokenFundsDispute is DisputeResolverRole {

    IERC20 _disputedToken;
    uint _disputedAmount;
    IERC20 _rewardToken;
    uint _rewardAmount;
    address _party1;
    address _party2;

    event DisputeResolved(
        IERC20 disputedToken, 
        address indexed party1, 
        uint party1Amount,
        address indexed party2,
        uint party2Amount, 
        IERC20 rewardToken,
        uint rewardAmount,
        address indexed rewardedTo
    );

    constructor (
        IERC20 disputedToken,
        uint disputedAmount,
        IERC20 rewardToken,
        uint rewardAmount,
        address party1,
        address party2
    )
        public 
    {
        _disputedToken = disputedToken;
        _disputedAmount = disputedAmount;
        _rewardToken = rewardToken;
        _rewardAmount = rewardAmount;
        _party1 = party1;
        _party2 = party2;
    }

    /**
     * @dev Resolve the dispute by transfering an amount to the first party and another amount to the
     * second party.  Caller gains the reward amount of reward tokens in the process.
     */
    function resolve(uint party1Amount, uint party2Amount) public onlyDisputeResolver {
        _resolve(party1Amount, party2Amount);
    }

    /**
     * @dev Resolve the dispute in favor of the first party.  Caller gains the reward amount of reward tokens in the process.
     */
    function resolveToPartyOne() public onlyDisputeResolver {
        _resolve(_disputedAmount, 0);
    }

    /**
     * @dev Resolve the dispute in favor of the second party.  Caller gains the reward amount of reward tokens in the process.
     */
    function resolveToPartyTwo() public onlyDisputeResolver {
        _resolve(0, _disputedAmount);
    }

    function _resolve(uint party1Amount, uint party2Amount) private {
        require(party1Amount + party2Amount == _disputedAmount);
        _disputedToken.transfer(_party1, party1Amount);
        _disputedToken.transfer(_party2, party2Amount);
        _rewardToken.transfer(msg.sender, _rewardAmount);
        emit DisputeResolved(_disputedToken, _party1, party1Amount, _party2, party2Amount, _rewardToken, _rewardAmount, msg.sender);

        /// TODO: get an answer on whether the event is easily accessible after self destruct.  the event is needed
        selfdestruct(address(uint160(msg.sender)));
    }

}