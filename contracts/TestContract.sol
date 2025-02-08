// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TestContract {
    event Deployed(address sender);

    constructor() {
        emit Deployed(msg.sender);
    }
}