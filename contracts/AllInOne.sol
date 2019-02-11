pragma solidity ^0.5.0;

interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
    function approve(address _spender, uint _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


interface ERC223 {
    function transfer(address _to, uint _value, bytes calldata _data) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

contract Token {
    string internal _symbol;
    string internal _name;
    uint8 internal _decimals;
    uint internal _totalSupply = 1000;
    mapping (address => uint) internal _balanceOf;
    mapping (address => mapping (address => uint)) internal _allowances;
    
    constructor(string memory symbol, string memory name, uint8 decimals, uint totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory)  {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    
    function balanceOf(address _addr) public view returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}

contract KPay is Token("KPY", "KPay", 18, 1000000), ERC20, ERC223 {
    address public creator;
    
    constructor() public {
        _balanceOf[msg.sender] = _totalSupply;
        creator = msg.sender;
    }
    
    struct IdentityData {
        string pubKey;
    }

    mapping (string => IdentityData) identities;
    mapping (string => uint) usageCount;

    function strConcat(string memory _a, string memory _b) public pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        uint i;
        for (i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }
    
    
    function CreateNewIdentity(string memory identifier, string memory pubKey) public returns (bool){
        if (_balanceOf[msg.sender] > 1) {
            _balanceOf[creator] += 1;
            _balanceOf[msg.sender] -= 1;
            identities[identifier].pubKey = pubKey;
            return true;
        }
        return false;
    }
    
    function GetIdentityJson(string memory identifier) public view returns (string memory) {
        string memory _pubKey = identities[identifier].pubKey;
        string memory jsonStr = "{pubKey: ";
        jsonStr = strConcat(jsonStr, _pubKey);
        jsonStr = strConcat(jsonStr, "}");
        return jsonStr;
    } 
    
    function GetUsageCount(string memory addr) public view returns (uint) {
        return usageCount[addr];
    }

    function IncrementUsageCount(string memory addr) public returns (bool) {
        usageCount[addr] =  usageCount[addr] + 1;
        return true;
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    
    function balanceOf(address _addr) public view returns (uint) {
        return _balanceOf[_addr];
    }

    function transfer(address _to, uint _value) public returns (bool) {
        if (_value > 0 && 
            _value <= _balanceOf[msg.sender] &&
            !isContract(_to)) {
            _balanceOf[msg.sender] -= _value;
            _balanceOf[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transfer(address _to, uint _value, bytes calldata _data) external returns (bool) {
        if (_value > 0 && 
            _value <= _balanceOf[msg.sender] &&
            isContract(_to)) {
            _balanceOf[msg.sender] -= _value;
            _balanceOf[_to] += _value;
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
            _contract.tokenFallback(msg.sender, _value, _data);
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    function isContract(address _addr) public view returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            _allowances[_from][msg.sender] >= _value &&
            _balanceOf[_from] >= _value) {
            _balanceOf[_from] -= _value;
            _balanceOf[_to] += _value;
            _allowances[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
    
    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint) {
        return _allowances[_owner][_spender];
    }
}