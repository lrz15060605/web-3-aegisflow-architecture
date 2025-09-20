// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

contract AegisAccount {
    using ECDSA for bytes32;

    address public owner;
    uint256 public nonce;

    event Executed(address indexed target, uint256 value, bytes data, bytes result);

    struct Intent {
        address target;
        uint256 value;
        bytes data;
        uint256 nonce;
        uint256 deadline; // block.timestamp <= deadline
    }

    // EIP-712 domain separator parts
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 private constant INTENT_TYPEHASH = keccak256(
        "Intent(address target,uint256 value,bytes data,uint256 nonce,uint256 deadline)"
    );

    bytes32 private constant NAME_HASH = keccak256(bytes("AegisAccount"));
    bytes32 private constant VERSION_HASH = keccak256(bytes("1"));

    constructor(address _owner) {
        owner = _owner;
    }

    function domainSeparator() public view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                NAME_HASH,
                VERSION_HASH,
                block.chainid,
                address(this)
            )
        );
    }

    function hashIntent(Intent memory intent) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                INTENT_TYPEHASH,
                intent.target,
                intent.value,
                keccak256(intent.data),
                intent.nonce,
                intent.deadline
            )
        );
    }

    function _toTypedDataHash(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator(), structHash));
    }

    function exec(Intent calldata intent, bytes calldata signature) external payable returns (bytes memory) {
        require(block.timestamp <= intent.deadline, "intent expired");
        require(intent.nonce == nonce, "bad nonce");

        bytes32 digest = _toTypedDataHash(hashIntent(intent));
        address signer = ECDSA.recover(digest, signature);
        require(signer == owner, "bad signature");

        // consume nonce first
        nonce++;

        (bool ok, bytes memory res) = intent.target.call{value: intent.value}(intent.data);
        require(ok, "call failed");
        emit Executed(intent.target, intent.value, intent.data, res);
        return res;
    }

    receive() external payable {}
}
