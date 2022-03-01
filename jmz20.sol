//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
*/
contract JMZ  {
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _total;
    mapping(address => uint256) private _handler;
    mapping(address => mapping(address => uint256)) private _allowances;
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 total_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _total = total_;
        _owner = msg.sender;
        _handler[msg.sender] = _total;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory){
        return _symbol;
    }

    function decimals() public view virtual returns (uint8){
        return _decimals;
    }
    
    function totalSupply() public view virtual returns (uint256){
        return _total;
    }

    function balanceOf(address owner) public view virtual returns (uint256){
        require(_owner != address(0), "ERC20: balance query for the zero address");
        return _handler[owner];
    }

    function transfer(address to, uint256 value) public virtual  returns (bool) {
        address form = _msgSender();
        _transfer(form, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool){
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual returns (bool){
        address owner = _msgSender();
        _spendAllowance(from, owner, amount);
        _transfer(from, to, amount);
        return true;
    }


    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _transfer(address from, address to,uint256 amount) internal virtual{
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _handler[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _handler[from] = fromBalance - amount;
        }
        _handler[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        require(_allowances[owner][spender] >= amount,"ERC20: insufficient allowance");
        _approve(owner, spender, _allowances[owner][spender] - amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual{
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}