// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal stub for FHEVM.sol for compilation purposes.
// For real deployment, use the official Zama FHEVM Solidity library from https://github.com/zama-ai/fhevm

// Dummy types for compilation
struct euint8 { uint8 v; }
struct euint32 { uint32 v; }

library FHEVM {
    function asEuint8(bytes calldata) internal pure returns (euint8 memory) { return euint8(0); }
    function eq(euint8 memory, euint8 memory) internal pure returns (euint32 memory) { return euint32(0); }
    function trivialEncrypt_uint8(uint8) internal pure returns (euint8 memory) { return euint8(0); }
    function add(euint32 memory, euint32 memory) internal pure returns (euint32 memory) { return euint32(0); }
    function decrypt(euint32 memory) internal pure returns (uint32) { return 0; }
}
