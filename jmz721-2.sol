// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyNft is
    Initializable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    bool public isSaleActive = false;
    bool public revealed = false;
    string public blindBoxURI;

    string public baseURI;
    string public baseExtension = ".json";

    uint256 public maxSupply = 10;
    uint256 public maxMintAmount = 1;
    uint256 public cost = 0.01 ether;
    bool public paused = false;

    constructor(string memory _blindBoxURI, string memory _initBaseURI)
        initializer
    {
        __ERC721_init("MyNFT", "MN");
        __Ownable_init();
        setBlindBoxURI(_blindBoxURI);
        setBaseURI(_initBaseURI);
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setBlindBoxURI(string memory _blindBoxURI) public onlyOwner {
        blindBoxURI = _blindBoxURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setSaleActive(bool _isSaleActive) public virtual onlyOwner {
        isSaleActive = _isSaleActive;
    }

    function setRevealed() public virtual onlyOwner {
        revealed = true;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function mint(address _to, uint256 _mintAmount) public payable {
        require(isSaleActive, "no sales opened");
        require(!paused, "paused mint");
        require(
            _mintAmount > 0,
            "the number of mint token must be greater then 0"
        );
        require(
            _mintAmount <= maxMintAmount,
            "the number of mint token has been exceeded"
        );
        require(_mintAmount * cost <= msg.value, "not enough ether sent");

        require(
            totalSupply() + _mintAmount <= maxSupply,
            "the maximum number of supports has been exceeded"
        );
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, totalSupply() + 1);
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!revealed) {
            return blindBoxURI;
        }

        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenId.toString(), baseExtension)
                )
                : "";
    }

    function withdraw(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }
}
