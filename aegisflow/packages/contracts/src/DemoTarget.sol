// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DemoTarget {
    event Ping(address indexed from, uint256 value, uint256 x);

    uint256 public lastX;

    function ping(uint256 x) external payable returns (uint256) {
        lastX = x;
        emit Ping(msg.sender, msg.value, x);
        return x + 1;
    }
}
