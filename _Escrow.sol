// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Escrow{
    //VARIABLES
    enum State {NOT_INITIATED, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE}

    State public currentState;

    uint public price;

    bool public buyerIn;
    bool public sellerIn;
    address public buyer;
    address payable public seller;

    //MODIFIERS
    modifier onlyBuyer(){
        require(msg.sender == buyer);
        _; 
    }

    modifier inState(State _state){
        require(currentState == _state);
        _;
    }

    //FUNCTIONS
    constructor(address _buyer, address payable _seller, uint _price){
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
    }

    function initContract() public inState(State.NOT_INITIATED){
        if (msg.sender == buyer){
            buyerIn = true;
        }
        if (msg.sender == seller){
            sellerIn = true;
        }
        if (buyerIn && sellerIn){
            currentState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() public payable onlyBuyer inState(State.AWAITING_PAYMENT){
        require(msg.value == price, "Must deposit agreed value");
        currentState = State.AWAITING_DELIVERY;
    }

    function withdraw() public payable onlyBuyer inState(State.AWAITING_DELIVERY){
        payable(msg.sender).transfer(price);
        currentState = State.COMPLETE;
    }

    function deliveryConfirmation() public onlyBuyer payable inState(State.AWAITING_DELIVERY){
        seller.transfer(price);
        currentState = State.COMPLETE;
    }

}
