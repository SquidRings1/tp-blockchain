// script/DeployCounter.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VestingWallet.sol";

contract DeployVestingWallet is Script {
    function run() external {
        // obtention du token ERC20 depuis le .env
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        vm.startBroadcast();
        new VestingWallet(tokenAddress);
        vm.stopBroadcast();
    }
}
