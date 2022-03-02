//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}

interface IERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC721Enumerable /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

contract JMZ is IERC721,IERC165,IERC721Metadata{
    use Strings for uint256;

    string private _name;
    string private _symbol;
    uint256 private _total;

    address private _owner;
    bool public _isSaleActive = false;
    bool public _revealed = false;

    string private _baseURI;
    string private _notRevealedUri;
    string public _baseExtension = ".json"

    mapping(address => uint256) private _handlers;
    mapping(uint256 => address) private _tokenIds;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping (address=>bool) ) private _operatorApprovals;

    modifier onlyOwner(){
        require(_owner == _msgSender,"Ownable: caller is not the owner");
        _;
    }

    function _msgSender() internal virtual returns(address){
        return msg.sender;
    }

    constructor (string memory name_, string memory symbol_, uint256 total_, string memory initBaseURI_, string memory initNotRevealedUri_){
        _name= name_
        _symbol = symbol_;
        _total = total_;
        setBaseURI(initBaseURI_);
        setNotRevealedURI(notRevealedUri);
        _owner = _msgSender()
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory){
        return _symbol;
    }
    function tokenURI(uint256 _tokenId) public view virtual override returns (string){
        require(_tokenId<=_total, "ERC721Metadata: URI query for nonexistent token");
        
        if (!_revealed) {
            return _notRevealedUri;
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString(), baseExtension));
    }

    function balanceOf(address _owner) public view virtual override returns (uint256){
        require(_owner != address(0), "ERC721: balance query for the zero address");
        
        return condition[address];
    }

    function ownerOf(uint256 _tokenId) public view virtual override returns (address){
        require(_revealed, "ERC721: The blind box has not been opened");
        address owner = _owners[tokenId];
        require(owner != address(0),"ERC721: owner query for nonexistent token");
        return owner;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        require(_isApprovedOrOwner(_msgSender(), _tokenId),"ERC721: transfer caller is not owner nor approved");

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        safeTransferFrom(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        require(_isApprovedOrOwner(_msgSender(), _tokenId),"ERC721: transfer caller is not owner nor approved")
        _transfer(_from,_to,_tokenId)
    }

    function _transfer(address _from, address _to, uint256 _tokenId, bytes data) internal virtual {
        _transfer(_from, _to, _tokenId);
        _;
    }

    function approve(address _approved, uint256 _tokenId) external payable{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        address owner = ownerOf(_tokenId)
        require(owner == _msgSender() || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all");
        _approve(_approved, _tokenId)
    }


    function setApprovalForAll(address _operator, bool _approved) external{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        _setApprovalForAll(__msgSender(), _operator,_approved)
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approved) {
        require(_owner != _operator,"ERC721: approve to caller");
        _operatorApprovals[owner][operator] = _approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _isApprovedOrOwner(address _owner, uint256 _tokenId) internal virtual returns(bool){
        address owner = ownerOf(_tokenId)
        return owner == _owner|| _operatorApprovals[owner][_owner]
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), _tokenId);
        _handlers[_from] -= 1;
        _handlers[_to] += 1;
        _tokenIds[_tokenId] = to;
        emit Transfer(_from, _to, _tokenId);
    }

    function _approve(address _approved, uint256 _tokenId) internal virtual {
         _tokenApprovals[_tokenId] = _approved;
    }


    function getApproved(uint256 _tokenId) external view returns (address){
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        return _tokenApprovals[_tokenId]
    }

    function isApprovedForAll(address _owner, address _operator) internal view returns (bool){
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        return _operatorApprovals[_owner][_operator]
    }
    
    
    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        return interfaceID == type(ERC721).interfaceId || interfaceID == type(ERC721Metadata).interfaceId || interfaceId == type(ERC165).interfaceId;
    }

    // function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){

    // }

    function flipSaleActive() public onlyOwner{
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }
    function setBaseURI(string baseuri_){
        _baseURI = baseuri_;
    }
    function setNotRevealedURI(string notRevealedUri_) {
        _notRevealedUri = notRevealedUri_;
    }
}