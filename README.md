# Technology
### -> Solidity
### -> Truffle
### -> Ganache

# What did I learn?
## Function Selector
When a function is called, the first 4 bytes of calldata specifies which function to call.
This 4 bytes is called a function selector.
```
data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
```
## Custom Error Messages
```
  error TxIdNotUnique(bytes32 txId);
  error TxNotQueued(bytes32 txId);
  error TimestampNotWithinTimeWindow(uint timestamp, uint start, uint end);
  error TxExecutionFailed(bool status, bytes res);
 ```
## Hashing and Encoding Methods
```
function getTxId(
  address _target,
  uint _value,
  bytes memory _data,
  string memory _func,
  uint _timestamp
) private pure returns (bytes32) {
  return keccak256(abi.encode(_target, _value, _data, _func, _timestamp));
}
```
```
data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
```

## Events and their importance
```
event Cancel(bytes32 txId);
event Response(bool success, bytes data);
event Queue(address _target, uint _value, bytes _data, string _func, uint _timestamp);
event Execute(address _target, uint _value, bytes  _data, string  _func, bytes32 _txId, int _timestamp);
```
