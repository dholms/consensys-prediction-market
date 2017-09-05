pragma solidity ^0.4.12;

import "./Question.sol";

contract PredictionMarket{

    mapping(address => bool) isAdmin;
    address[] questions;

    modifier adminOnly(){
        require(isAdmin[msg.sender] == true);
        _;
    }

    function PredictionMarket(){
        isAdmin[msg.sender] = true;
    }

    function addQuestion(string questionText) public adminOnly() returns(address question){
        address newQuestion =  new Question(questionText);
        questions.push(newQuestion);
        return newQuestion;
    }

    function resolveQuestion(Question question, bool resolution) public adminOnly() returns(bool success){
        return question.resolve(resolution);
    }

    function addTrustedUser(Question question, address user) public adminOnly() returns(bool success){
        return question.addTrustedUser(user);
    }

    function addAdmin(address newAdmin) public adminOnly() returns(bool success){
        isAdmin[newAdmin] = true;
        return true;
    }
}
