// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.13;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf( address account) external view returns (uint256);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf og `owner` through {transferFrom}.  This is
     * zero by default.
     * 
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance( address owner , address spender ) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the callers account to `recipient`.
     *
     * Returns a boolean value indicating if the operation succeeded.
     *
     * Emits a {Transafer} event.
     */
    function transfer( address recipient , uint256 amount ) external returns (bool);

    /**
     * @dev Sets `amount` as the allowance of `spender` over a the caller's tokens.
     *
     * Returns a boolean value indicating if the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve( address spender , uint256 amount ) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism.  `amount` is then deducted from the caller's
     * allwance.
     *
     * Returns a boolean value indicating if the operation succeeded.
     * 
     * Emits a {Transfer} event.
     */
    function transferFrom( address sender , address recipient , uint256 amount ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer( address indexed from , address indexed to , uint256 value );

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}.  `value` is the new allowance.
     */
    event Approval( address indexed owner , address indexed spender , uint256 value );
}