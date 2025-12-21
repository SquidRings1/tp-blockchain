// script/DeployCounter.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VestingWallet.sol";

contract DeployVestingWallet is Script {
    function run() external {
        address tokenAddress = vm.envUint("TOKEN_ADDRESS");
        vm.startBroadcast();
        new VestingWallet(tokenAddress);
        vm.stopBroadcast();
    }
}