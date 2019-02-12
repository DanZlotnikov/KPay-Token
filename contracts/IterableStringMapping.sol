pragma solidity ^0.5.0;

library IterableStringMapping
{
    struct itmap 
    {
        mapping (uint => string) data;
        uint size;
    }

    function insert(itmap storage self, string memory value) public returns (bool) {
        uint index = self.size;
        self.data[index] = value;
        self.size = self.size + 1;
        return true;
    }

    function get(itmap storage self, uint index) public returns (string memory) {
        return self.data[index];
    }

    function size(itmap storage self) public returns (uint) {
        return self.size;
    }
}

contract TestMapping {
    IterableStringMapping.itmap data;

    function get(uint index) public returns (string memory) {
        return IterableStringMapping.get(data, index);
    }

    function insert(string memory value) public returns (bool) {
        return IterableStringMapping.insert(data, value);
    }

    function size() public returns (uint) {
        return IterableStringMapping.size(data);
    }
}