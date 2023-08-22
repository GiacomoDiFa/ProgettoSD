// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketSale {
    address public owner;
    //uint256 public totalTickets;
    //uint256 public ticketsSold;
    uint256 public totalEvents;
    //uint256 public newEventId;

    struct Event {
        string name;
        string description;
        uint256 totalTickets;
        uint256 ticketsSold;
        uint256 ticketPrice;
    }

    // events[eventId] == Event(...)
    mapping(uint256 => Event) public events;
    // ticketsPurchased[msg.sender][eventId] == numTicketsPurchased
    mapping(address => mapping(uint256 => uint256)) public ticketsPurchased;

    event TicketPurchased(address indexed buyer, uint256 eventId, uint256 numTickets);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        //totalTickets = _totalTickets;
        //ticketsSold = 0;
        totalEvents = 0;
        //newEventId = 0;
    }

    function createEvent(string memory name, string memory description, uint256 _totalTickets, uint256 ticketPrice) external onlyOwner {
        require(_totalTickets > 0, "Number of total tickets must be > 0");
        
        // ID evento
        //newEventId++;
        //events[newEventId] = Event(name, description, _totalTickets, 0, ticketPrice);
        events[totalEvents] = Event(name, description, _totalTickets, 0, ticketPrice);
        totalEvents++;
    }
    
    function buyTickets(uint256 eventId, uint256 numTickets) external payable {
        Event storage currentEvent = events[eventId];
        require(currentEvent.totalTickets > 0, "Event does not exist");
        require(numTickets > 0, "You must buy at least one ticket");
        //require(ticketsSold + numTickets <= totalTickets, "Not enough tickets available");
        require(currentEvent.ticketsSold + numTickets <= currentEvent.totalTickets, "Not enough tickets available for this event");
        require(msg.value >= currentEvent.ticketPrice * numTickets, "Insufficient payment");

        ticketsPurchased[msg.sender][eventId] += numTickets;
        //ticketsSold += numTickets;
        currentEvent.ticketsSold += numTickets;

        uint amountToSend = currentEvent.ticketPrice * numTickets;
        uint change = msg.value - amountToSend;
        // gli ether dentro msg.value sono tutti inviati a allo SC (default)
        //payable(address(this)).transfer(amountToSend); 
        // resto al mittente
        payable(msg.sender).transfer(change);

        emit TicketPurchased(msg.sender, eventId, numTickets);
    }

    // da rivedere
    event TicketReselled(address indexed seller, address indexed buyer, uint256 eventId, uint256 numTickets);

    // chi chiama la funzione paga ed e' il buyer
    function resellTickets(address seller, uint256 eventId, uint256 numTickets) external payable {
        Event storage currentEvent = events[eventId];
        require(currentEvent.totalTickets > 0, "Event does not exist");
        require(msg.sender != seller, "Seller and Buyer must be different");
        require(numTickets > 0, "You must buy at least one ticket");
        require(ticketsPurchased[seller][eventId] >= numTickets, "Not enough tickets available");
        require(msg.value >= currentEvent.ticketPrice * numTickets, "Insufficient payment");

        // NB funzioni successive
        require(ticketsToResell[seller][eventId] >= numTickets, "Not enough tickets to resell");

        ticketsToResell[seller][eventId] -= numTickets;

        ticketsPurchased[seller][eventId] -= numTickets;
        ticketsPurchased[msg.sender][eventId] += numTickets;
        
        //NB msg.value va tutto allo SC che poi inoltra i soldi
        uint amountToSend = currentEvent.ticketPrice * numTickets;
        uint change = msg.value - amountToSend;
        // Transfer the amount to the seller
        payable(seller).transfer(amountToSend); 
        // resto al mittente
        payable(msg.sender).transfer(change);

        emit TicketReselled(seller, msg.sender, eventId, numTickets);
    }

    // flag per sapere quanti biglietti voglio vendere
    // ticketsToResell[msg.sender][eventId] == numTicketsToResell
    mapping(address => mapping(uint256 => uint256)) public ticketsToResell;
    event WantToResell(address indexed reseller, uint256 eventId, uint256 numTickets);

    function wantToResell(uint256 eventId, uint256 _numTickets) external {
        require(ticketsPurchased[msg.sender][eventId] >= _numTickets, "Not enough tickets to resell");
        ticketsToResell[msg.sender][eventId] += _numTickets;

        emit WantToResell(msg.sender, eventId, _numTickets);
    }

    // getter per il msg.sender (facoltativo)
    function getMyTicketsToResell(uint256 eventId) external view returns (uint256) {
        return ticketsToResell[msg.sender][eventId];
    }

    // da rivedere se funziona
    // rimborso ticket (only owner?)
    function refundTickets(uint256 eventId, uint256 numTickets) external {
        Event storage currentEvent = events[eventId];
        require(currentEvent.totalTickets > 0, "Event does not exist");
        require(numTickets > 0, "You must refund at least one ticket");
        require(ticketsPurchased[msg.sender][eventId] >= numTickets, "You don't have enough tickets to refund");

        uint256 balance = address(this).balance;
        uint256 refundAmount = currentEvent.ticketPrice * numTickets;
        require(balance >= refundAmount, "Smart Contract balance is not sufficient");

        ticketsPurchased[msg.sender][eventId] -= numTickets;
        //ticketsSold -= numTickets;
        currentEvent.ticketsSold -= numTickets;

        // Transfer the refund amount to the buyer           
        // Funziona (paga lo SC)
        payable(msg.sender).transfer(refundAmount);
    }


    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawAllFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Contract has no balance");
        payable(msg.sender).transfer(balance);
    }

    // MI SA CHE NON HA MOLTO SENSO, LO TOGLIAMO?
    /*
    // single event
    function withdrawFunds(uint256 eventId) external onlyOwner {
        Event storage currentEvent = events[eventId];
        require(currentEvent.totalTickets > 0, "Event does not exist");

        // i soldi vengono dal balance dello SC
        uint256 totalRefund = currentEvent.ticketPrice * currentEvent.ticketsSold;
        uint256 balance = address(this).balance;
        require(balance >= totalRefund, "Contract has not enough balance");
    
        payable(msg.sender).transfer(totalRefund);
    }
    */

    function getMyTicketCount(uint256 eventId) external view returns (uint256) {
        return ticketsPurchased[msg.sender][eventId];
    }

    function getRemainingTickets(uint256 eventId) external view returns (uint256) {
        Event storage currentEvent = events[eventId];
        return currentEvent.totalTickets - currentEvent.ticketsSold;
    }

    function getTicketPrice(uint256 eventId) external view returns (uint256) {
        return events[eventId].ticketPrice;
    }

    function totalTickets() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < totalEvents; i++) {
            total += events[i].totalTickets;
        }
        return total;
    }

    function totalTicketsSold() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < totalEvents; i++) {
            total += events[i].ticketsSold;
        }
        return total;
    }

    function totalTicketsAvailable() external view returns (uint256) {
        return this.totalTickets() - this.totalTicketsSold();
    }
    
    // funzioni in piu' (opzionali) CHAT GPT
    // sono troppe?

    // modifica evento
    function editEvent(uint256 eventId, string memory name, string memory description, uint256 _totalTickets, uint256 _ticketPrice) external onlyOwner {
        Event storage currentEvent = events[eventId];
        require(currentEvent.totalTickets > 0, "Event does not exist");
        require(_totalTickets >= currentEvent.ticketsSold, "Total tickets must be more than tickets sold");
    
        currentEvent.name = name;
        currentEvent.description = description;
        currentEvent.totalTickets = _totalTickets;
        currentEvent.ticketPrice = _ticketPrice;
    }

    /*
    // lista eventi
    // e' corretta? serve?
    function listEvents() external view returns (Event[] memory) {
        Event[] memory eventList = new Event[](totalEvents);
        for (uint256 i = 0; i < totalEvents; i++) {
            eventList[i] = events[i];
        }
        return eventList;
    }
    */

    // sold out event
    function isEventSoldOut(uint256 eventId) external view returns (bool) {
        Event storage currentEvent = events[eventId];
        return currentEvent.ticketsSold >= currentEvent.totalTickets;
    }

    function getTotalEvents() public view returns (uint256){
        return totalEvents;
    }
}