// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract Erc20ICO is ERC20Upgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    uint256 minCost = 0.01 ether;

    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __ERC20_init(_name, _symbol);
        __Ownable_init();
    }

    receive() external payable {
        require(
            msg.value > minCost,
            "the latest purchase amount is 0.01 ether"
        );
        uint256 amount = msg.value * 1000000;
        super._mint(_msgSender(), amount);
    }

    function withdraw(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }
}
