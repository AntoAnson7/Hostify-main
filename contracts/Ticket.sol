pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Ticket {
    struct Tickets {
        bytes32 eventId;
        bytes32 userId;
        bytes32 ticketId;
        bool isValid;
    }

    mapping(bytes32 => Tickets) public ticketsByTicketId;
    mapping(bytes32 => bytes32[]) public ticketsByUserId;

    event TicketCreated(bytes32 indexed ticketId, bytes32 indexed eventId, bytes32 indexed userId);
    event TicketInvalidated(bytes32 indexed ticketId, bytes32 indexed eventId, bytes32 indexed userId);

    uint256 private lastTicketId;

    function createTicket(bytes32 eventId, bytes32 userId) external returns (bytes32) {
        require(eventId != bytes32(0), "Invalid event ID");
        require(userId != bytes32(0), "Invalid user ID");

        bytes32 ticketId = generateRandomTicketId();

        Tickets memory newTicket = Tickets({
            eventId: eventId,
            userId: userId,
            ticketId: ticketId,
            isValid: true
        });

        ticketsByTicketId[ticketId] = newTicket;
        ticketsByUserId[userId].push(ticketId);

        emit TicketCreated(ticketId, eventId, userId);

        return ticketId;
    }

    function generateRandomTicketId() internal view returns (bytes32) {
        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        bytes32 ticketId = bytes32(randomValue % 100000000); // Ensure 8-digit value
        return ticketId;
    }

    function getTicketsByUser(bytes32 userId) external view returns (Tickets[] memory) {
        require(userId != bytes32(0), "Invalid user ID");

        bytes32[] memory ticketIds = ticketsByUserId[userId];
        Tickets[] memory userTickets = new Tickets[](ticketIds.length);

        for (uint256 i = 0; i < ticketIds.length; i++) {
            bytes32 ticketId = ticketIds[i];
            userTickets[i] = ticketsByTicketId[ticketId];
        }

        return userTickets;
    }

    function invalidateTicket(bytes32 ticketId) external {
        require(ticketId != bytes32(0), "Invalid ticket ID");

        Tickets storage ticket = ticketsByTicketId[ticketId];

        require(ticket.eventId != bytes32(0), "Ticket does not exist");
        require(ticket.isValid, "Ticket is already invalid");

        ticket.isValid = false;

        emit TicketInvalidated(ticketId, ticket.eventId, ticket.userId);
    }

    function getTicketDetails(bytes32 ticketId) external view returns (Tickets memory) {
        require(ticketId != bytes32(0), "Invalid ticket ID");

        return ticketsByTicketId[ticketId];
    }
}