pragma solidity ^0.4.12;

import "./Question.sol";

contract PredictionMarket is Stoppable{

    mapping(address => bool) isAdmin;
    address[] questions;
    mapping(address => bool) questionExists;

    modifier onlyIfQuestion(address question){ require(questionExists[question]); _;}

    event LogQuestionCreated(address createdBy,address question);
    event LogQuestionStopped(address sender, address question);
    event LogQuestionStarted(address sender, address question);
    event LogQuestionNewOwner(address sender, address question, address newOwner);

    modifier onlyAdmin(){
        require(isAdmin[msg.sender] == true);
        _;
    }

    function PredictionMarket(){
        isAdmin[msg.sender] = true;
    }

    function createQuestion(string questionText) onlyAdmin returns(address question){
        address newQuestion =  new Question(msg.sender, questionText);
        questions.push(newQuestion);
        questionExists[newQuestion] = true;
        return newQuestion;
    }

    function addAdmin(address newAdmin) onlyAdmin returns(bool success){
        isAdmin[newAdmin] = true;
        return true;
    }

    // Pass-through Admin Controls

    function stopQuestion(address question) onlyOwner onlyIfQuestion(question) returns(bool success){
        Question trustedQuestion = Question(question);
        LogQuestionStopped(msg.sender, question);
        return trustedQuestion.runSwitch(false);
    }

    function startQuestion(address question) onlyOwner onlyIfQuestion(question) returns(bool success){
        Question trustedQuestion = Question(question);
        LogQuestionStarted(msg.sender, question);
        return trustedQuestion.runSwitch(true);
    }

    function changeQuestionOwner(address question, address newOwner) onlyOwner onlyIfQuestion(question) returns(bool success){
        Question trustedQuestion = Question(question);
        LogQuestionNewOwner(msg.sender, question, newOwner);
        return trustedQuestion.changeOwner(newOwner);
    }
}
