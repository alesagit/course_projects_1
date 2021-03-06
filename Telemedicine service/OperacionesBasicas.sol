// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

contract OperacionesBasicas{
    
    using SafeMath for uint256;

    constructor() internal{}

    function calcularPrecioTokens(uint _numTokens) internal pure returns (uint){
        return _numTokens.mul(1 ether);
    }
    function getBalance() public view returns(uint ethers){
        return payable(address(this)).balance;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString){
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}