// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

pragma solidity ^0.8.20;

contract PerezosoGiveaway is ReentrancyGuard {
    enum GiveawayState {
        active,
        inactive
    }

    IERC20 private _token;
    uint256 public maxTicket;
    uint256 public ENTRY_FEE;
    uint256 public PRIZE;
    address[] public currentPlayers;
    uint256 public giveawayCount = 0;
    address[] winners;
    address public owner;
    address public recievingWallet;
    uint256 public hour;
    uint256 public minute;
    uint256 public totalRewardDistributed;
    Leaderboard[] public leaderboard;

    struct Leaderboard {
        address winner;
        uint256 prize;
        uint256 timestamp;
    }

    GiveawayState public giveaway_state = GiveawayState.active;

    constructor(
        IERC20 _tokenContract,
        address _recievingWallet,
        uint256 _entryfee,
        uint256 _prize,
        uint256 _hour,
        uint256 _minutes,
        uint256 _maxTicket
    ) {
        _token = _tokenContract;
        owner = msg.sender;
        recievingWallet = _recievingWallet;
        ENTRY_FEE = _entryfee;
        PRIZE = _prize;
        hour = _hour;
        minute = _minutes;
        maxTicket = _maxTicket;
    }

    modifier toBeInState(GiveawayState status) {
        require(giveaway_state == status, "Not in needed state");
        _;
    }

    modifier onlyAtGiveAwayTime() {
        require(
            (block.timestamp % 86400) / 3600 == hour &&
                ((block.timestamp % 3600) / 60) == minute,
            "Can not execute at this time"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setPayoutTime(uint256 _hour, uint256 _minute) public onlyOwner {
        hour = _hour;
        minute = _minute;
    }

    function EnterGiveaway(uint256 _tickets)
        public
        toBeInState(GiveawayState.active)
        nonReentrant
    {
        require(
            _tickets <= maxTicket,
            "Ticket entered is above maximum ticket"
        );
        uint256 priceToPay = _tickets * (ENTRY_FEE * (10**18));
        require(
            priceToPay <= _token.balanceOf(msg.sender),
            "Your balance is not enough!"
        );
        for (uint256 i = 0; i < _tickets; i++) {
            currentPlayers.push(msg.sender);
        }
        _token.transferFrom(msg.sender, recievingWallet, priceToPay);
    }

    function getWinner()
        external
        onlyAtGiveAwayTime
        nonReentrant
        returns (address)
    {
        require(currentPlayers.length != 0, "No players available");

        uint256 randomNumber = generateUniqueNumber() % currentPlayers.length;
        address winner = currentPlayers[randomNumber];

        bool success = _token.transfer(winner, (PRIZE * (10**18)));
        require(success, "Prize transfer failed");
        winners.push(winner);
        delete currentPlayers;
        giveawayCount += 1;
        totalRewardDistributed += PRIZE;
        Leaderboard memory newEntry = Leaderboard(
            winner,
            PRIZE,
            block.timestamp
        );
        leaderboard.push(newEntry);
        return winner;
    }

    function setGiveawayState(GiveawayState state) public onlyOwner {
        giveaway_state = state;
    }

    function setRecievingWallet(address _wallet) public onlyOwner {
        recievingWallet = _wallet;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setEntryFee(uint256 entryfee) public onlyOwner {
        ENTRY_FEE = entryfee;
    }

    function setMaxTicket(uint256 _maxTicket) public onlyOwner {
        maxTicket = _maxTicket;
    }

    function setPrize(uint256 _prize) public onlyOwner {
        PRIZE = _prize;
    }

    function generateUniqueNumber() private view returns (uint256) {
        uint256 uniqueNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    currentPlayers.length,
                    msg.sender
                )
            )
        );
        return uniqueNumber;
    }

    function getCurrentPlayers() public view returns (address[] memory) {
        return currentPlayers;
    }

    function getCurrentGiveawayCount() public view returns (uint256) {
        return giveawayCount;
    }

    function getAllWiners() public view returns (address[] memory) {
        return winners;
    }

     function getLeaderboard() public view returns (Leaderboard[] memory) {
        return leaderboard;
    }

    function getMaxTicket() public view returns (uint256) {
        return maxTicket;
    }

    function getIERC20Token() public view returns (IERC20) {
        return _token;
    }

    function updateERC20Token(IERC20 _tokenContract) public onlyOwner {
        _token = _tokenContract;
    }

    function withdrawERC20Token(address _to) public onlyOwner {
        _token.transfer(_to, _token.balanceOf(address(this)));
    }
}