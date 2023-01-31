  // SPDX-License-Identifier: GPL-3.0
  pragma solidity ^0.8.0;

  contract oracle{

  
  function latestRoundData()
    external
    pure
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ){
        return (0,1570 * 1e8,0,0,0);
    }
  }
  