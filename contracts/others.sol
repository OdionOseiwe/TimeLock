// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Testtoken is ERC20("others", "TT"){

    function mint(address to, uint amount) external {
        _mint(to,amount *10** 18);
    }
}  