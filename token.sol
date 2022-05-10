// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.13;

import "./IERC20.sol";
import "./SafeMath.sol";
//import "./extensions/IERC20Metadata.sol";
//import "../../utils/Context.sol";

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
            currentAllowance >= subtractedValue,
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

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`'s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to set
     * automatic allowances for certain subsystems, etc...
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *   - `owner` cannot be the zero address
     *   - `spender` cannot be the zero address
     */
     function _approve(
         address owner,
         address spender,
         uint256 amount
     ) internal virtual {
         require(
             owner != address( 0 ),
             "ERC20: approve from the zero address"
         );
         require(
             spender != address( 0 ),
             "ERC20: approve to the zero address"
         );
         _allowances[ owner ][ spender ] = amount;
         emit Approval( owner , spender , amount );
     }

    /**
     * @dev Updates `owner`'s allowance for `spender1 based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * May emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance( owner , spender);
        if(
            currentAllowance != type( uint256 ).max
            ){
                require(
                    currentAllowance >= amount,
                    "ERC20: insufficient allowance"
                );
                unchecked {
                    _approve(
                        owner,
                        spender,
                        currentAllowance - amount
                        );
                }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens.  This includes
     * minting and burning.
     *
     * Calling conditions:
     *   - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     *     will be transfered to `to`.
     *   - when `from` is zero, `amount` tokens will be minted for `to`.
     *   - `from` and `to` are never both zero
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens.  This includes
     * minting and burning.
     *
     * Calling conditions:
     *   - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     *     have been transferred to `to`.
     *   - when `from` is zero, `amount` tokens have been minted for `to`.
     *   - when `to` is zero, `amount of `from`'s tokens have been burned.
     *   - `from` and `to` are never both zero.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}