// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {VestingWallet} from "../src/VestingWallet.sol";

contract theKoken is ERC20 {
    constructor() ERC20 ("xwingtoken", "XT") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract VestingWalletTest is Test {
    VestingWallet public vesting;
    theKoken public token;

    address public owner;
    address public beneficiary1;

    uint256 constant AMOUNT = 1;
    uint256 constant CLIFF = 30 days;
    uint256 constant DURATION = 365 days;

    function setUp() public {
        owner = address(this);
        beneficiary1 = address(0x1);

        token = new theKoken();
        vesting = new VestingWallet(address(token));
        token.approve(address(vesting), AMOUNT);
    }

    function testCreateVesting() public {
        vesting.createVestingSchedule(beneficiary1, AMOUNT, CLIFF, DURATION);
        (address beneficiary, uint256 cliff, uint256 duration, uint256 totalAmount, uint256 releasedAmount) = vesting.vestingSchedules(beneficiary1);
        assertEq(totalAmount, AMOUNT);
    }
}
