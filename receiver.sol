pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IIndexSwap.sol";
import "./IWETH.sol";


contract ReceiverIndex is IXReceiver {
  // Number of pings this contract has received from the Ping contract
  uint256 public pings;

  IIndexSwap public index;

  // The connext contract deployed on the same domain as this contract
  IConnext public immutable connext;


  constructor(IConnext _connext, IIndexSwap _index) {
    connext = _connext;
    index = _index;
  }

  /** 
   * @notice The receiver function as required by the IXReceiver interface.
   * @dev The Connext bridge contract will call this function.
   */
  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory) {
    // Because this call is *not* authenticated, the _originSender will be the Zero Address
    // Ping's address was sent with the xcall so it could be decoded and used for the nested xcall
    (address user) = abi.decode(_callData, (address));

    IERC20 _token = IERC20(_asset);
    uint256 balance = _token.balanceOf(address(this));

    IWETH weth = IWETH(_asset);
    weth.withdraw(balance);

    // IIndexSwap index = IIndexSwap(_index);

    index.investInFund{value: balance} (user);
    
  }
}