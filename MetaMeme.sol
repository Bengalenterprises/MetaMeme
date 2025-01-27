// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MetaMeme is IERC20 {
    string public name = "MetaMeme";
    string public symbol = "MME";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 1000000000000 * 10 ** uint256(decimals); // 1 trillion tokens

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public liquidityFee = 2; // 2% to liquidity
    uint256 public creatorFee = 1; // 1% to meme creators
    uint256 public charityFee = 1; // 1% to charity
    address public liquidityWallet;
    address public creatorWallet;
    address public charityWallet;

    constructor(address _liquidityWallet, address _creatorWallet, address _charityWallet) {
        liquidityWallet = _liquidityWallet;
        creatorWallet = _creatorWallet;
        charityWallet = _charityWallet;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(_balances[sender] >= amount, "Insufficient balance");

        uint256 liquidityAmount = (amount * liquidityFee) / 100;
        uint256 creatorAmount = (amount * creatorFee) / 100;
        uint256 charityAmount = (amount * charityFee) / 100;
        uint256 transferAmount = amount - (liquidityAmount + creatorAmount + charityAmount);

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[liquidityWallet] += liquidityAmount;
        _balances[creatorWallet] += creatorAmount;
        _balances[charityWallet] += charityAmount;

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, liquidityWallet, liquidityAmount);
        emit Transfer(sender, creatorWallet, creatorAmount);
        emit Transfer(sender, charityWallet, charityAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
