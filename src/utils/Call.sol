// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

library Call {
    /**
     * @dev Call to the target using the given data. Revert when error occurs.
     * @param _target The target address to call.
     * @param _data The data used in the call.
     */
    function call(address _target, bytes memory _data) internal returns (bytes memory) {
        (bool success, bytes memory result) = _target.call(_data);
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
        }
        return result;
    }

    /**
     * @dev Call to the target using the given data and value. Revert when error occurs.
     * @param _target The target address to call.
     * @param _data The data used in the call.
     * @param _value The value to send in the call.
     */
    function callWithValue(address _target, bytes memory _data, uint256 _value) internal returns (bytes memory) {
        (bool success, bytes memory result) = _target.call{value: _value}(_data);
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
        }
        return result;
    }

    /**
     * @dev Pay to the target using the given value. Revert when error occurs.
     * @param _target The target address to pay.
     * @param _value The value to send in the call.
     */
    function pay(address _target, uint256 _value) internal {
        (bool success,) = _target.call{value: _value}("");
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }
}
