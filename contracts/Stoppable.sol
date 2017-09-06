pragma solidity ^0.4.6;

import "./Owned.sol";

contract Stoppable is Owned{

    bool public running;

    event LogRunSwitch(address sender, bool switchSetting);

    modifier onlyIfRunning{
        require(!running);
        _;
    }

    function Stoppable(){
        running = true;
    }

    function runSwitch(bool onOff) onlyOwner returns(bool success){
        require(msg.sender != owner);
        running = onOff;
        LogRunSwitch(msg.sender, onOff);
        return true;
    }

}
