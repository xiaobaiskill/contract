//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC721 /* is ERC165 */ {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external ;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external ;
    function transferFrom(address _from, address _to, uint256 _tokenId) external ;
    function approve(address _approved, uint256 _tokenId) external ;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

interface IERC721Metadata /* is ERC721 */ {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC721Enumerable /* is ERC721 */ {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

contract JMZ is IERC721,IERC165,IERC721Metadata{
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    uint256 private _total;

    address private _owner;
    bool public _isSaleActive = false;
    bool public _revealed = false;

    string private _baseURI;
    string private _notRevealedUri;
    string public _baseExtension = ".json";

    mapping(address => uint256) private _handlers;
    mapping(uint256 => address) private _tokenIds;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping (address=>bool) ) private _operatorApprovals;

    modifier onlyOwner(){
        require(_owner == _msgSender(),"Ownable: caller is not the owner");
        _;
    }

    function _msgSender() internal virtual returns(address){
        return msg.sender;
    }

    constructor (string memory name_, string memory symbol_, uint256 total_, string memory initBaseURI_, string memory initNotRevealedUri_){
        _name= name_;
        _symbol = symbol_;
        _total = total_;
        setBaseURI(initBaseURI_);
        setNotRevealedURI(initNotRevealedUri_);
        _owner = _msgSender();
        _handlers[_owner] = total_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory){
        return _symbol;
    }
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory){
        require(_tokenId<=_total, "ERC721Metadata: URI query for nonexistent token");
        
        if (!_revealed) {
            return _notRevealedUri;
        }
        return string(abi.encodePacked(_baseURI, _tokenId.toString(), _baseExtension));
    }

    function balanceOf(address owner_) public view virtual override returns (uint256){
        require(owner_ != address(0), "ERC721: balance query for the zero address");
        
        return _handlers[owner_];
    }

    function ownerOf(uint256 tokenId_) public view virtual override returns (address){
        require(_revealed, "ERC721: The blind box has not been opened");
        address owner = _tokenIds[tokenId_];
        require(owner != address(0),"ERC721: owner query for nonexistent token");
        return owner;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public virtual override{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        require(_isApprovedOrOwner(_msgSender(), _tokenId),"ERC721: transfer caller is not owner nor approved");
        _transfer(_from, _to, _tokenId, data); 
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public virtual override{
        safeTransferFrom(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public virtual override{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        require(_isApprovedOrOwner(_msgSender(), _tokenId),"ERC721: transfer caller is not owner nor approved");
        _transfer(_from,_to,_tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId, bytes memory data) internal virtual {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function approve(address _approved, uint256 _tokenId) public virtual override{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        address owner = ownerOf(_tokenId);
        require(owner == _msgSender() || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all");
        _approve(_approved, _tokenId);
    }


    function setApprovalForAll(address _operator, bool _approved) public virtual override{
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        _setApprovalForAll(_msgSender(), _operator,_approved);
    }

    function _setApprovalForAll(address owner, address operator, bool approved)  internal virtual{
        require(owner != operator,"ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _isApprovedOrOwner(address owner_, uint256 tokenId_) internal virtual returns(bool){
        address owner = ownerOf(tokenId_);
        return owner == owner_|| _operatorApprovals[owner][owner_];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(ownerOf(_tokenId) == _from, "ERC721: transfer from incorrect owner");
        require(_to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), _tokenId);
        _handlers[_from] -= 1;
        _handlers[_to] += 1;
        _tokenIds[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try 
                IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                    return retval == IERC721Receiver.onERC721Received.selector;
                } 
            catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _approve(address _approved, uint256 _tokenId) internal virtual {
         _tokenApprovals[_tokenId] = _approved;
    }


    function getApproved(uint256 _tokenId) public  view  virtual override returns (address){
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address owner_, address operator_) public view virtual override returns (bool){
        require(_isSaleActive,"ERC721: No sales opened");
        require(_revealed, "ERC721: The blind box has not been opened");

        return _operatorApprovals[owner_][operator_];
    }
    
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool){
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function flipSaleActive() public virtual onlyOwner{
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public virtual onlyOwner {
        _revealed = !_revealed;
    }
    function setBaseURI(string memory baseuri_) public virtual{
        _baseURI = baseuri_;
    }
    function setNotRevealedURI(string memory notRevealedUri_)public virtual {
        _notRevealedUri = notRevealedUri_;
    }
}