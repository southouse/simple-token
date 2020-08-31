pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract SampleToken is ERC20Detailed, ERC20, Ownable {
    constructor(string name, string symbol, uint8 decimals, uint256 totalSupply)

    ERC20Detailed(name, symbol, decimals)

    public {
        _mint(owner(), totalSupply * 10 ** uint(decimals));
    }

    bool private canPausedTransfer = true;
    bool private pausedTransfer = false;

    modifier whenPausedTransferStatus {
        require(pausedTransfer, "This contract hasn't paused transfer.");
        _;
    }

    modifier whenNotPausedTransferStatus {
        require(!pausedTransfer || msg.sender == owner(), "This contract has been paused transfer.");
        _;
    }

    event Transfer(address to, uint256 value);
    event TransferFrom(address from, address to, uint256 value);

    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);

    mapping (address => uint256) public percentLockAccount;
    mapping (address => bool) public isPercentLockAccount;
    event PercentLockAccount(address target, uint8 percent);
    event IsPercentLockAccount(address target);

    event PauseTransfer();
    event UnPauseTransfer();
    // event UnPausable();

    function pauseTransfer() onlyOwner whenNotPausedTransferStatus public returns (bool) {
        require(canPausedTransfer, "This smart contract can't control transfer");
        pausedTransfer = true;
        emit PauseTransfer();
        return true;
    }

    function unPauseTransfer() onlyOwner whenPausedTransferStatus public returns (bool) {
        require(canPausedTransfer, "This smart contract can't control transfer");
        require(pausedTransfer, "Already this smart contract has been paused transfer");
        pausedTransfer = false;
        emit UnPauseTransfer();
        return true;
    }
    
    function transferStatus() public view returns (bool) {
        return pausedTransfer;
    }

    // function unPausable() onlyOwner public {
    //     require(canPausedTransfer, "This smart contract can't control transfer");
    //     canPausedTransfer = false;
    //     pausedTransfer = false;
    //     emit UnPausable();
    // }

    function transfer(address to, uint256 value) public whenNotPausedTransferStatus returns (bool) {
        require(!frozenAccount[msg.sender], "This account has been frozen.");
        require(!frozenAccount[to], "This account has been frozen.");
        if (isPercentLockAccount[msg.sender]) {
            require(value <= percentLockAccount[msg.sender], "Over transfer more than lock value.");
            percentLockAccount[msg.sender] = percentLockAccount[msg.sender].sub(value);
        }
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPausedTransferStatus returns (bool) {
        require(!frozenAccount[from], "This account has been frozen.");
        require(!frozenAccount[to], "This account has been frozen.");
        if (isPercentLockAccount[from]) {
            require(value <= percentLockAccount[from], "Over transfer more than lock value.");
            percentLockAccount[from] = percentLockAccount[from].sub(value);
        }
        _transferFrom(from, to, value);
        emit TransferFrom(from, to, value);
        return true;
    }

    function burnOnlyOwner(address target, uint256 value) onlyOwner public {
        _burn(target, value);
    }

    function mintOnlyOwner(address target, uint256 value) onlyOwner public {
        _mint(target, value);
    }

    function freeze(address target, bool _freeze) public {
        frozenAccount[target] = _freeze;
        emit FrozenFunds(target, _freeze);
    }

    function percentLockAccount(address target, uint8 percent) onlyOwner public returns (bool) {
        percentLockAccount[target] = balanceOf(target) * (100 - percent) / 100;
        isPercentLockAccount[target] = true;
        emit PercentLockAccount(target, percent);
        emit IsPercentLockAccount(target);
        return true;
    }

    function percentUnlockAccount(address target) onlyOwner public returns (bool) {
        require(isPercentLockAccount[target], "This account is already unlock.");
        percentLockAccount[target] = 0;
        isPercentLockAccount[target] = false;
        emit IsPercentLockAccount(target);
        return true;
    }
}