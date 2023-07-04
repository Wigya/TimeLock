// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract OwnTimeLock {
  error TxIdNotUnique(bytes32 txId);
  error TxNotQueued(bytes32 txId);
  error TimestampNotWithinTimeWindow(uint timestamp, uint start, uint end);
  error TxExecutionFailed(bool status, bytes res);

  constructor() {
    owner = msg.sender;
  }

  receive() external payable {}

  uint constant MIN_DELAY = 100; // seconds
  uint constant MAX_DELAY = 1000; // seconds
  uint constant GRACE_TIME = 1000; // seconds

  event Cancel(bytes32 txId);
  event Response(bool success, bytes data);
  event Queue(address _target, uint _value, bytes _data, string _func, uint _timestamp);
  event Execute(address _target, uint _value, bytes  _data, string  _func, bytes32 _txId, int _timestamp);

  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner may execute this function");
    _;
  }

  mapping(bytes32 => bool) public isTxIdQueued;

  address public owner;

  function getTxId(
    address _target,
    uint _value,
    bytes memory _data,
    string memory _func,
    uint _timestamp
  ) private pure returns (bytes32) {
    return keccak256(abi.encode(_target, _value, _data, _func, _timestamp));
  }

  function queue(
    address _target,
    uint _value,
    bytes calldata _data,
    string calldata _func,
    uint _timestamp
  ) external onlyOwner {
    // create tx id
    bytes32 txId = getTxId(_target, _value, _data, _func, _timestamp);
    // check tx id unique
    if (isTxIdQueued[txId]) revert TxIdNotUnique(txId);
    // check timestamp
    if (
      _timestamp < block.timestamp + MIN_DELAY ||
      _timestamp > block.timestamp + MAX_DELAY
    )
      revert TimestampNotWithinTimeWindow(
        _timestamp,
        block.timestamp + MIN_DELAY,
        block.timestamp + MAX_DELAY
      );
    // queue tx
    isTxIdQueued[txId] = true;
  }

  function execute(
    address _target,
    uint _value,
    bytes calldata _data,
    string calldata _func,
    uint _timestamp
  ) external payable onlyOwner returns (bytes memory) {
    bytes32 txId = getTxId(_target, _value, _data, _func, _timestamp);
    // check if tx is queued
    if (!isTxIdQueued[txId]) {
      revert TxNotQueued(txId);
    }

    // check if timestamp is within the specified time window
    uint currentTimestamp = block.timestamp;
    if (
      (currentTimestamp < _timestamp ||
        currentTimestamp > _timestamp + GRACE_TIME)
    )
      revert TimestampNotWithinTimeWindow(
        currentTimestamp,
        _timestamp,
        GRACE_TIME + _timestamp
      );

    // delete tx from queue
    isTxIdQueued[txId] = false;

    // execute the tx
    bytes memory data;
    if (bytes(_func).length > 0) {
      data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
    } else {
      data = _data;
    }

    (bool success, bytes memory res) = _target.call{value: _value}(data);
    if (!success) revert TxExecutionFailed(success, res);

    emit Response(success, res);
    return res;
  }

  function cancel(bytes32 _txId) external {
    if (!isTxIdQueued[_txId]) revert TxNotQueued(_txId);

    isTxIdQueued[_txId] = false;

    emit Cancel(_txId);
  }
  
}


contract TestTimeLock {
  address public timeLock;

  constructor(address _timeLock) {
    timeLock = _timeLock;
  }

  function test() external {
    require(msg.sender == timeLock, "not timelock");
    // more code here such as
    // - upgrade contract
    // - transfer funds
    // - switch price oracle
  }
}
