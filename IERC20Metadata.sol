// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.13;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
 interface IERC20Metadata is IERC20 {
     /**
      * @dev Returns the name of the token.
      */
    function name () external view returns (string memory);

    /**
     * @dev Returns the symbol of the Token
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimal places of the token.
     */
    function decimals() external view returns(uint8);
 }