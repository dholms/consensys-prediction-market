pragma solidity ^0.4.12;

contract Question{

    string  public question;
    uint    public betYesAmount;
    uint    public betNoAmount;
    bool    public isResolved;
    bool    public isYes;

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

    modifier trustedOnly(){
        require(isTrusted[msg.sender] == true);
        _;
    }

    function Question(string _question){
        question = _question;
        isTrusted[msg.sender] = true;
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

    function resolve(bool _isYes) public trustedOnly() returns(bool success){
        require(isResolved == false);
        isResolved = true;
        isYes = _isYes;
        LogResolution(_isYes);
        return true;
    }

    function addTrustedUser(address toAdd) public trustedOnly() returns(bool success){
        isTrusted[toAdd] = true;
        return true;
    }
}
