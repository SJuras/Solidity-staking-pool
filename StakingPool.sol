// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;


contract StakingPool {
  // set admin
  address public admin;
  // when does the period end
  uint public end;

  bool public finalized;

  uint public totalInvested;

  uint public totalChange;

  // address and balance of each investor
  mapping(address => uint) public balances;

  // which investor claimed their change
  mapping(address => bool) public changeClaimed;

  event NewInvestor(
    address investor
    );

  constructor(){
    admin = msg.sender;
    // period ends one year after deployment
    end = block.timestamp + 365 days;
  }

  function invest() external payable {
    // make sure its not too late to invest.
    require(block.timestamp < end, "Too late, period ended.");
    // if its a new investor -> emit event to inform us of the new investor.
    if(balances[msg.sender] == 0){
      emit NewInvestor(msg.sender);
    }
    balances[msg.sender] += msg.value;
  }

  function finalize(){
    require(block.timestamp >= end, "Too early");
    require(finalized == false, "ALready finalized");
    finalized = true;
    totalInvested = address(this).balance;
    totalChange = address(this).balance % 32 ether;
  }

  function getChange(){
    require(finalized == true, "Not yet finalized");
    require(balances[msg.sender] > 0, "Not an investor");
    require(changeClaimed[msg.sender] == false, "change already claimed");
    changeClaimed[msg.sender] = true;
    uint amount = totalChange * balances[msg.sender] / totalInvested;
    msg.sender.transfer(amount);
  }



}
