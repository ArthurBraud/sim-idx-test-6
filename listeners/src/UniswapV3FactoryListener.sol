// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "sim-idx-generated/Generated.sol";

/// Index calls to the UniswapV3Factory.createPool function on Ethereum
/// To hook on more function calls, specify that this listener should implement that interface and follow the compiler errors.
contract UniswapV3FactoryListener is UniswapV3Factory$OnCreatePoolFunction {
    /// Emitted events are indexed.
    /// To change the data which is indexed, modify the event or add more events.
    event TokenMetadata(string name, string symbol);

    /// The handler called whenever the UniswapV3Factory.createPool function is called.
    /// Within here you write your indexing specific logic (e.g., call out to other contracts to get more information).
    /// The only requirement for handlers is that they have the correct signature, but usually you will use generated interfaces to help write them.
    function onCreatePoolFunction(
        FunctionContext memory _ctx,
        UniswapV3Factory$CreatePoolFunctionInputs memory inputs,
        UniswapV3Factory$CreatePoolFunctionOutputs memory _outputs
    ) external override {
        // Token A metadata
        string memory name = getName(inputs.tokenA);
        string memory symbol = getSymbol(inputs.tokenA);
        emit TokenMetadata(name, symbol);

        // Token B metadata  .
        name = getName(inputs.tokenB);
        symbol = getSymbol(inputs.tokenB);
        emit TokenMetadata(name, symbol);
    }

    function canBeString(bytes memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let size := mload(b)

            switch gt(size, 63)
            case 0 { result := 0 }
            default {
                // sub(mload(b), 64) is the returndata length minus the 2 first words (offset and string size).
                // mload(add(b, 64)) is the size of the string, written in the 2nd word.
                // We check whether the size of the string is smaller or equal than the size of the returndata part corresponding to the string.
                // Since we cannot do greater or equal, we use sub(mload(b), 63) instead of sub(mload(b), 64).
                result := gt(sub(mload(b), 63), mload(add(b, 64)))
            }
        }
    }

    function getName(address tokenAddress) internal returns (string memory name) {
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSignature("name()"));

        if (success && canBeString(data)) {
            name = abi.decode(data, (string));
        } else {
            return "";
        }
    }

    function getSymbol(address tokenAddress) internal returns (string memory symbol) {
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSignature("symbol()"));

        if (success && canBeString(data)) {
            symbol = abi.decode(data, (string));
        } else {
            return "";
        }
    }

    function getMetadata(address addr) public returns (string memory name, string memory symbol) {
        return (getName(addr), getSymbol(addr));
    }
}
