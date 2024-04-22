// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WesyncToken is ERC20, Ownable {
    using SafeMath for uint256;

    IERC20 private _usdtToken;
    uint256 private _totalValue = 1000;
    mapping(address => uint8) _balances;

    constructor(address initialOwner)
        ERC20("WeSync", "WSTK")
        Ownable(initialOwner)
    {
        _usdtToken = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
        _mint(address(this), 1000 * 10 ** decimals());
    }

    function isOwner() private view returns (bool) {
        return owner() == msg.sender;
    }

    function currentWstkAmount() private view returns (uint256) {
        return ERC20(address(this)).balanceOf(address(this));
    }

    function getPrice() public view returns (uint256) {
       (bool valid, uint256 value) = (_totalValue * 10 ** decimals()).tryDiv(currentWstkAmount());

        require(valid, "Invalid sub operation");

        return value;
    }

    
    function swap(uint256 amount) public {
        uint256 clientUSDTBalance = _usdtToken.balanceOf(msg.sender);
        (, uint256 price) = amount.tryMul(getPrice());

        require(clientUSDTBalance >= price, "Client doesn't have enough USDT");

        require(currentWstkAmount() <= 50 * 10 ** decimals(), "Not enough tokens in the smart contract");

        bool usdtSent = _usdtToken.transferFrom(msg.sender, owner(), amount);
        require(usdtSent, "Failed to transfer USDT from client to smart contract owner");

        ERC20(address(this)).transferFrom(address(this), msg.sender, amount);
    }

    function checkBuyerAmount(uint256 amount) private view {
        (, uint256 buyerAmount) = ERC20(address(this)).balanceOf(msg.sender).tryAdd(amount);
        require(buyerAmount >= 100 * 10 ** decimals(), "Total buyer amount cannot be greater than 100 WSTKK");
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}