// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

abstract contract Proxy {
    constructor() {}

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _implementation() internal view virtual returns (address);

    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _willFallback() internal virtual {}

    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

contract ProxyAdmin is Proxy {
    address private owner;
    address private implementation;
    //确保只有所有者可以运行这个函数
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //设置管理者owner地址
    constructor() {
        owner = msg.sender;
    }

    //更新实现合约地址
    function upgradeTo(address _newImplementation) external onlyOwner {
        require(implementation != _newImplementation);
        _setImplementation(_newImplementation);
    }

    //设置当前实现地址
    function _setImplementation(address _newImp) internal {
        implementation = _newImp;
    }

    function _implementation() internal view override returns (address) {
        return implementation;
    }
}

/*

contract StorageStructure {
    using SafeMathUpgradeable for uint256;
    uint256 public totalPlayers;
    mapping (address => uint256) public points;
}


contract ImplementationV1 is StorageStructure { 
    function addPlayer(address _player, uint256 _points) public virtual {
        require (points[_player] == 0);
        points[_player] = _points;
    }
    function setPoints(address _player, uint256 _points) public virtual {
        require (points[_player] != 0);
        points[_player] = _points;
    }
}



contract ImplementationV2 is ImplementationV1 {
    function addPlayer(address _player, uint256 _points) public override
    {
        require (points[_player] == 0);
        points[_player] = _points;
        totalPlayers++;
    }

    function setPoints(address _player, uint256 _points) public override {
        require (points[_player] != 0);
        points[_player] = _points;
    }

}

*/

contract ImplementationV1 {
    uint256 public totalPlayers = 1;
    mapping(address => uint256) public points;

    function addPlayer(address _player, uint256 _points) public virtual {
        require(points[_player] == 0);
        points[_player] = _points;
    }

    function setPoints(address _player, uint256 _points) public virtual {
        require(points[_player] != 0);
        points[_player] = _points;
    }
}

contract ImplementationV2 {
    uint256 public totalPlayers;
    mapping(address => uint256) public points;

    function addPlayer(address _player, uint256 _points) public virtual {
        require(points[_player] == 0);
        points[_player] = _points;
        totalPlayers++;
    }

    function setPoints(address _player, uint256 _points) public virtual {
        require(points[_player] != 0);
        points[_player] = _points;
    }
}
