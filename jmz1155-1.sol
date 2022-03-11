// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract MyToken is
    OwnableUpgradeable,
    ERC1155Upgradeable,
    PausableUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string public name = "My Token";
    string public symbol = "MT";
    string public baseURL;
    string public baseExtension = ".json";

    mapping(address => bool) public minters;

    modifier onlyMinter() {
        require(
            minters[_msgSender()] || owner() == _msgSender(),
            "Mint: caller is not the minter"
        );
        _;
    }

    struct box {
        uint256 id;
        string name;
        uint256 mintNum;
        uint256 openNum;
        uint256 totalSupply;
        uint256 price;
        bool isBlindBox;
        bool isActive;
    }
    mapping(uint256 => box) public boxMap;

    modifier existsBox(uint256 boxID_) {
        require(boxID_ > 0, "invalid box");
        require(boxMap[boxID_].id > 0, "box does not exist");
        _;
    }

    constructor(string memory url_) initializer {
        __ERC1155_init(url_);
        __Ownable_init();
        baseURL = url_;
    }

    function newBox(
        uint256 boxID_,
        string memory name_,
        uint256 totalSupply_,
        uint256 price_,
        bool isBlindBox_
    ) public onlyOwner {
        require(boxID_ > 0, "invalid box");
        require(boxMap[boxID_].id == 0, "box already exists");
        boxMap[boxID_] = box({
            id: boxID_,
            name: name_,
            mintNum: 0,
            openNum: 0,
            totalSupply: totalSupply_,
            price: price_,
            isBlindBox: isBlindBox_,
            isActive: false
        });
    }

    function updateBox(
        uint256 boxID_,
        string memory name_,
        uint256 totalSupply_,
        uint256 price_
    ) public onlyOwner existsBox(boxID_) {
        require(
            !boxMap[boxID_].isActive,
            "box active is turned and cannot be set"
        );
        require(
            totalSupply_ > boxMap[boxID_].mintNum,
            "insufficient totalsupply"
        );

        boxMap[boxID_] = box({
            id: boxID_,
            name: name_,
            mintNum: boxMap[boxID_].mintNum,
            openNum: boxMap[boxID_].openNum,
            totalSupply: totalSupply_,
            price: price_,
            isBlindBox: boxMap[boxID_].isBlindBox,
            isActive: boxMap[boxID_].isActive
        });
    }

    function setBoxBatchAction(uint256[] memory boxIDs_, bool isActive_)
        public
        onlyOwner
    {
        require(boxIDs_.length > 0, "invalid box");
        for (uint256 i = 0; i < boxIDs_.length; i++) {
            uint256 boxID_ = boxIDs_[i];
            require(boxMap[boxID_].id > 0, "box does not exist");
            boxMap[boxID_].isActive = isActive_;
        }
    }

    function mint(
        address to_,
        uint256 boxID_,
        uint256 num_
    ) public payable onlyMinter whenNotPaused existsBox(boxID_) returns (bool) {
        require(boxMap[boxID_].isActive, "box active is not beginning");
        require(
            boxMap[boxID_].totalSupply >= boxMap[boxID_].mintNum + num_,
            "mint number is insufficient"
        );
        require(
            boxMap[boxID_].price * num_ <= msg.value,
            "not enough ether sent"
        );

        boxMap[boxID_].mintNum += num_;
        _mint(to_, boxID_, num_, "");
        return true;
    }

    function mintBatch(
        address to_,
        uint256[] memory boxIDs_,
        uint256[] memory nums_
    ) public payable onlyMinter whenNotPaused {
        require(boxIDs_.length == nums_.length, "array length unequal");
        uint256 cost = 0;
        for (uint256 i = 0; i < boxIDs_.length; i++) {
            require(boxIDs_[i] > 0, "invalid box");
            require(boxMap[boxIDs_[i]].id > 0, "box does not exist");
            require(boxMap[boxIDs_[i]].isActive, "box active is not beginning");
            require(
                boxMap[boxIDs_[i]].totalSupply >=
                    boxMap[boxIDs_[i]].mintNum + nums_[i],
                "mint number is insufficient"
            );
            cost = (boxMap[boxIDs_[i]].price * nums_[i]) + cost;
        }
        require(cost <= msg.value, "not enough ether sent");

        for (uint256 i = 0; i < boxIDs_.length; i++) {
            boxMap[boxIDs_[i]].mintNum += nums_[i];
            _mint(to_, boxIDs_[i], nums_[i], "");
        }
    }

    function burn(
        address from_,
        uint256 boxID_,
        uint256 num_
    ) public whenNotPaused {
        require(
            _msgSender() == from_ || isApprovedForAll(from_, _msgSender()),
            "burn caller is not owner nor approved"
        );
        _burnSingle(from_, boxID_, num_);
    }

    function burnBatch(
        address from_,
        uint256[] memory boxIDs_,
        uint256[] memory nums_
    ) public whenNotPaused {
        require(boxIDs_.length == nums_.length, "array length unequal");
        require(
            _msgSender() == from_ || isApprovedForAll(from_, _msgSender()),
            "burn caller is not owner nor approved"
        );
        for (uint256 i = 0; i < boxIDs_.length; i++) {
            _burnSingle(from_, boxIDs_[i], nums_[i]);
        }
    }

    function _burnSingle(
        address from_,
        uint256 boxID_,
        uint256 num_
    ) internal existsBox(boxID_) {
        require(boxMap[boxID_].isActive, "box active is not beginning");
        if (boxMap[boxID_].isBlindBox) {
            // 如果是盲盒应该发放盲盒内的商品
        }
        _burn(from_, boxID_, num_);
    }

    function setMinter(address minter, bool power) public onlyOwner {
        minters[minter] = power;
    }

    function uri(uint256 boxID)
        public
        view
        virtual
        override
        returns (string memory)
    {
        // require
        return
            bytes(baseURL).length > 0
                ? string(
                    abi.encodePacked(baseURL, boxID.toString(), baseExtension)
                )
                : "";
    }

    function setURL(string memory newURL_) public onlyOwner {
        baseURL = newURL_;
    }

    function setPause(bool isPause) public onlyOwner {
        if (isPause) {
            _unpause();
        } else {
            _pause();
        }
    }

    function withdraw(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }
}
