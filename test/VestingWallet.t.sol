// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {VestingWallet} from "../src/VestingWallet.sol";

contract theKoken is ERC20 {
    constructor() ERC20 ("xwingtoken", "XT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract VestingWalletTest is Test {
    VestingWallet public vesting;
    theKoken public token;

    address public owner;
    address public beneficiary1;
    uint256 public startTime = 1000;

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

    // Test 1: Vérifier que la création d'un calendrier de vesting
    function testCreateVesting() public {
        vesting.createVestingSchedule(beneficiary1, AMOUNT, CLIFF, DURATION);
        (address beneficiary, uint256 cliff, uint256 duration, uint256 totalAmount, uint256 releasedAmount) = vesting.vestingSchedules(beneficiary1);

        // asserts
        assertEq(beneficiary, beneficiary1, "ERROR: le Beneficiary doit matcher !!!");
        assertEq(cliff, CLIFF, "ERROR: le cliff doit matcher !!!");
        assertEq(duration, DURATION, "ERROR: le duration doit matcher !!!");
        assertEq(totalAmount, AMOUNT, "ERROR: le total amount doit matcher !!!");
        assertEq(releasedAmount, 0, "ERROR: le release amount doit etre 0 !!!");
        assertEq(token.balanceOf(address(vesting)), AMOUNT);
    }

    // Test 2: Tenter de réclamer des jetons avant la date de cliff
    function testCannotClaimBeforeCliff() public {
        vesting.createVestingSchedule(beneficiary1, AMOUNT, CLIFF, DURATION);

        vm.warp(startTime - 1);
        vm.prank(beneficiary1);
        vm.expectRevert("ERROR: Aucun jeton disponible a reclamer !!!");
        vesting.claimVestedTokens();
    }
}
