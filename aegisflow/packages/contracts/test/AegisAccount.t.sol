// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {AegisAccount} from "../src/AegisAccount.sol";
import {DemoTarget} from "../src/DemoTarget.sol";

contract AegisAccountTest is Test {
    AegisAccount account;
    DemoTarget target;
    uint256 ownerPk = 0xA11CE; // test key
    address ownerAddr;

    function setUp() public {
        ownerAddr = vm.addr(ownerPk);
        account = new AegisAccount(ownerAddr);
        target = new DemoTarget();
        vm.deal(address(account), 10 ether);
    }

    function testExecWithSignature() public {
        AegisAccount.Intent memory intent = AegisAccount.Intent({
            target: address(target),
            value: 0,
            data: abi.encodeWithSignature("ping(uint256)", 42),
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                account.domainSeparator(),
                account.hashIntent(intent)
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPk, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(address(0xBEEF));
        account.exec(intent, sig);
        assertEq(target.lastX(), 42);
        assertEq(account.nonce(), 1);
    }
}
