// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {VestingWallet} from "../src/VestingWallet.sol";

contract theKoken is ERC20 {
    constructor() ERC20("the TOKEN", "TEST") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract VestingWalletTest is Test {
    VestingWallet public vesting;
    theKoken public token;

    constructor() {
        token = new theKoken();
        vesting = new VestingWallet(address(token));
    }
}
