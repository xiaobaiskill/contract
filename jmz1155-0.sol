// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// ipfs://QmXzreVkG1LSszH8m2nEi4dem9K3tXAWPUf8HKmDCjwn4s/{id}.json
// https://api.frank.hk/api/nft/demo/1155/marvel/{id}.json

contract MyToken is OwnableUpgradeable, ERC1155Upgradeable {
    string public name = "My Token";
    string public symbol = "MT";

    constructor(string memory url_) initializer {
        __ERC1155_init(url_);
        __Ownable_init();
        _mint(_msgSender(), 1, 10, "");
        _mint(_msgSender(), 2, 100, "");
    }

    function setUri(string memory uri_) public onlyOwner {
        _setURI(uri_);
        emit URI(uri_, 0);
    }
}
