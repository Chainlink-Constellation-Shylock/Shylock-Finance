// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract ERC20Mock is ERC20Upgradeable {

    function initialize(string memory name_, string memory symbol_) public initializer {
        ERC20Upgradeable.__ERC20_init(name_, symbol_);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        return ERC20Upgradeable.transferFrom(from, to, amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        return ERC20Upgradeable.transfer(to, amount);
    }

}