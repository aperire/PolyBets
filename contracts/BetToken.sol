// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.15;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract BetToken is ERC20 {
     constructor() ERC20("BET Token", "BET")
    {
        _mint(msg.sender, 100000000 * 10**18);
    }
}