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
    constructor( string memory name_, string memory symbol_, uint256 totalSupply_ ) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _totalSupply = totalSupply_;
        _balances[ msg.sender ] = _totalSupply;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf( address tokenOwner ) public override view returns (uint256) {
        return _balances[ tokenOwner ];
    }

    function transfer( address reciever , uint256 numTokens ) public override returns (bool) {
        require( numTokens <= _balances[ msg.sender ] );
        _balances[ msg.sender ] = _balances[ msg.sender ].sub( numTokens );
        _balances[ reciever ] = _balances[ reciever ].add( numTokens );
        emit Transfer( msg.sender , reciever , numTokens );
        return true;
    }

    function approve( address delegate , uint256 numTokens ) public override returns (bool) {
        _allowances[ msg.sender ][ delegate ] = numTokens;
        emit Approval( msg.sender , delegate , numTokens );
        return true;
    }

    function allowance( address owner , address delegate ) public override view returns (uint) {
        return _allowances[ owner ][ delegate ];
    }

    function transferFrom( address owner , address buyer , uint256 numTokens ) public override returns (bool) {
        require( numTokens <= _balances[ owner ] );
        require( numTokens <= _allowances[ owner ][ msg.sender ] );
        _balances[ owner ] = _balances[ owner ].sub( numTokens );
        _allowances[ owner ][ msg.sender ] = _allowances[ owner ][ msg.sender ].sub( numTokens );
        _balances[ buyer ] = _balances[ buyer ].add( numTokens );
        emit Transfer( owner , buyer , numTokens );
        return true;
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