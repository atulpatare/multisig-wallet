// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MultiSigWallet {
    address internal constant MASTER = address(0x1);

    mapping(address => address) internal owners;
    uint256 internal ownerCount;
    uint256 internal threshold;

    event OwnerAdded(address owner);
    event OwnerRemoved(address owner);
    
    modifier authorized () {
        require(msg.sender == address(this), "MS401");
        _;
    }

    function setup(address[] memory _owners, uint256 _threshold) public {
        require(_threshold > 0 && _threshold < _owners.length, "MS101");
        
        address currentOwner = MASTER;
        for(uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            _isValidAddress(owner);
            owners[currentOwner] = owner;
            currentOwner = owner;
        }

        owners[currentOwner] = MASTER;
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    function _isValidAddress(address _owner) private view {
            require(
                _owner != address(0) &&
                _owner != address(this) && 
                _owner != MASTER,
            "MS104");
            require(owners[_owner] == address(0), "MS103");
    }

    function addOwner(address _owner) public authorized {
        _isValidAddress(_owner);
        owners[_owner] = owners[MASTER];
        owners[MASTER] = _owner;
        ownerCount++;
        emit OwnerAdded(_owner);
    }

    function removeOwner(address prevOwner, address _owner) public authorized {
        require(owners[prevOwner] == _owner && _owner != MASTER, "MS402");
        owners[prevOwner] = owners[_owner];
        owners[_owner] = address(0);
        ownerCount--;
        emit OwnerRemoved(_owner);
    } 
}