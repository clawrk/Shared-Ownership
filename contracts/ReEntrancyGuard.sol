// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}