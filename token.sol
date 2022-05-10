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

contract ERC20 is IERC20 {
    /**
     * @dev
     */

    using SafeMath for uint256;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping( address => uint256 ) private _balances;
    mapping( address => mapping ( address => uint256 ) ) private _allowances;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decdimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable:  They can only be set once
     * during construction.
     */
    constructor(
        string memory name_, 
        string memory symbol_, 
        uint256 totalSupply_ 
        ) public {
            _name = name_;
            _symbol = symbol_;
            _decimals = 18;
            _totalSupply = totalSupply_;
            _balances[ msg.sender ] = _totalSupply;
        }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view virtual override returns (string memory) {
         return _symbol;
     }

    /**
     * @dev
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf( address account ) public view virtual override returns (uint256) {
        return _balances[ account ];
    }

    /**
     * @dev See {IERC20-transfer}.
     * 
     * Requirements:
     *   - `recipient` cannot be the zero address.
     *   - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address to, 
        uint256 amount 
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer( owner , to , amount );
        return true;
    }

    /**
     * @dev See {IERC20-approve}
     * 
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`.  This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *   - `spender` cannot be the zero address.
     */
    function approve(
        address spender, 
        uint256 amount 
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve( owner , spender , amount );
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner, 
        address spender 
    ) public view virtual override returns (uint256) {
        return _allowances[ owner ][ spender ];
    }

    /**
     * @dev See {IERC20-transferFrom}
     *
     * Emits an {Approval} event indicating the updated allowance.  This is not
     * required by the EIP.
     *
     * Requirements:
     *   - `from` and `to` cannot be zero address.
     *   - `from` must have a balance of at least ammount.
     *   - the caller must have allowance for `from`'s token of
     *     at least ammount.
     */
    function transferFrom(
        address from, 
        address to, 
        uint256 amount 
    ) public override returns (bool) {
        _spendAllowance( from , spender , amount );
        _transfer( from , to , amount );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternatice to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}
     *
     * Emits an {Approval} event indicating the updated allowance
     *
     * Requirements:
     *   - `spender` cannot be the zero address.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(
            owner,
            spender, 
            allowance( owner , spender) + addedValue
            );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve}} that can be used as a mitigation for
     * problems described in {IERC20-approve}
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *   - `spender` cannot be the zero address.
     *   - `spender` must at least have allowance for the caller of at least
     *     `subtractedValue`.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance( owner , spender );
        require(
            currentAlowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
            );
        unchecked {
            _approve( owner , spender , currentAllowance - subtractedValue );
        }
        return true;
    }

    /**
     * @dev Moves `mount` of tokens `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * impliment automatic token fees, slashing mechanisms, etc...
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *   - `from` cannot be zero address.
     *   - `to` cannot be zero address.
     *   - `from` must have balance of at least `ammount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(
            from != address( 0 ),
            "ERC20: transfer from the zero address"
        );
        require(
            to != address( 0 ),
            "ERC20: transfer to the zero address"
        );
        _beforeTokenTransfer( from , to , amount );
        uint256 fromBalance = _balances[ from ];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[ from ] = fromBalance - amount;
        }
        _balances[ to ] += amount;
        emit Transfer( from , to , amount );
        _afterTokenTransfer( from , to , amount );
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Rrequirements:
     *   - `account` cannot be the zero address.
     */
    function _mint(
        address account,
        uint256 amount
    ) internal virtual {
        require(
            account != address( 0 ),
            "ERC20: mint to the zero address"
        );
        _beforeTokenTransfer(
            address( 0 ),
            account,
            amount
        );
        _totalSupply += amount;
        _balances[ account ] += amount;
        emit Transfer(
            address( 0 ),
            account,
            amount
        );
        _afterTokenTransfer(
            address( 0 ),
            account,
            amount
        );
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *   - `account` cannot be the zero address.
     *   - `account` must have at leaset `amount` tokens.
     */
    function _burn(
        address account,
        uint256 amount
    ) internal virtual {
        require(
            account != address( 0 ),
            "ERC20; burn from zero address"
        );
        _beforeTokenTransfer(
            account,
            address( 0 ),
            amount
        );
        uint256 accountBalance = _balances[ account ];
        require(
            accountBalance >= amount,
            "ERC20: burn amount exceeds balalnce"
        );
        unchecked {
            _balances[ account ] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(
            account,
            address( 0 ),
            amount
        );
        _afterTokenTransfer(
            account,
            address( 0 ),
            amount
        );
    }

}

library SafeMath {
    function sub( uint256 a , uint256 b ) internal pure returns (uint256) {
        assert( b <= a );
        return a - b;
    }

    function add( uint256 a , uint256 b ) internal pure returns (uint256) {
        uint256 c = a + b;
        assert( c >= a );
        return c;
    }
}