pragma solidity ^0.4.12;

import "./Stoppable.sol";

contract Question is Stoppable{

    string  public question;
    uint    public betYesAmount;
    uint    public betNoAmount;
    bool    public isResolved;
    bool    public isYes;
    address public creator;

    mapping(address => Response) public responses;
    mapping(address => bool) public isTrusted;

    struct Response{
        uint bet;
        bool votedYes;
        bool hasWithdrawn;
    }

    event LogPrediction(address predictor, bool votedYes, uint betAmount);
    event LogResolution(bool resolvedYes);
    event LogWithdrawal(address withdrawer, uint amount);
    event LogTrustedUserAdded(address newAdmin);

    modifier onlyTrusted(){
        require(isTrusted[msg.sender] == true);
        _;
    }

    function Question(address _creator,string _question){
        creator = _creator;
        question = _question;
        isTrusted[creator] = true;
    }

    function predict(bool _isYes) public payable returns(bool success){
        require(msg.value > 0);
        require(responses[msg.sender].bet == 0);
        Response memory newResponse;
        newResponse.bet = msg.value;
        newResponse.votedYes = _isYes;
        newResponse.hasWithdrawn = false;
        responses[msg.sender] = newResponse;
        if(_isYes){
            betYesAmount += msg.value;
        }else{
            betNoAmount += msg.value;
        }
        LogPrediction(msg.sender, _isYes, msg.value);
        return true;
    }

    function withdraw() public returns(bool success){
        require(isResolved);
        require(responses[msg.sender].hasWithdrawn == false);
        require(responses[msg.sender].votedYes == isYes);
        uint bet = responses[msg.sender].bet;
        require(bet > 0);

        uint betCorrect;
        if(isYes){
            betCorrect= betYesAmount;
        }else{
            betCorrect = betNoAmount;
        }
        responses[msg.sender].hasWithdrawn = true;
        uint withdrawalAmount = bet*(betYesAmount+betNoAmount)/betCorrect;
        msg.sender.transfer(withdrawalAmount);
        LogWithdrawal(msg.sender, withdrawalAmount);

        return true;
    }

    function resolve(bool _isYes) onlyTrusted returns(bool success){
        require(isResolved == false);
        isResolved = true;
        isYes = _isYes;
        LogResolution(_isYes);
        return true;
    }

    function addTrustedUser(address toAdd) onlyTrusted returns(bool success){
        isTrusted[toAdd] = true;
        LogTrustedUserAdded(toAdd);
        return true;
    }
}
