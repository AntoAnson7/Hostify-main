pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Ticket {
    struct Tickets {
        bytes32 ticketId;
        bytes32 eventId;
        bytes32 userId;
        bool isValid;
        uint256 blockId;
        uint256 gasFee;
        uint256 blockTimestamp;
        bytes32 transactionId;
    }

    mapping(bytes32 => Tickets) public ticketsByTicketId;
    mapping(bytes32 => bytes32[]) public ticketsByUserId;
    mapping(bytes32 => bytes32[]) public ticketsByEventId;

    event TicketCreated(bytes32 indexed ticketId, bytes32 indexed eventId, bytes32 indexed userId);
    event TicketInvalidated(bytes32 indexed ticketId, bytes32 indexed eventId, bytes32 indexed userId);

    uint256 private lastTicketId;

    function createTicket(bytes32 eventId, bytes32 userId) external returns (bytes32) {
        require(eventId != bytes32(0), "Invalid event ID");
        require(userId != bytes32(0), "Invalid user ID");

        lastTicketId++;
        require(lastTicketId <= 99999999, "Maximum ticket ID limit reached");

        bytes32 ticketId = bytes32(lastTicketId);

        Tickets memory newTicket = Tickets({
            ticketId: ticketId,
            eventId: eventId,
            userId: userId,
            isValid: true,
            blockId: block.number,
            gasFee: tx.gasprice,
            blockTimestamp: block.timestamp,
            transactionId: bytes32(uint256(msg.sender) << 96)
        });

        ticketsByTicketId[ticketId] = newTicket;
        ticketsByUserId[userId].push(ticketId);
        ticketsByEventId[eventId].push(ticketId);

        emit TicketCreated(ticketId, eventId, userId);

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

    function getTicketsByEvent(bytes32 eventId) external view returns (Tickets[] memory) {
        require(eventId != bytes32(0), "Invalid event ID");

        bytes32[] memory ticketIds = ticketsByEventId[eventId];
        Tickets[] memory eventTickets = new Tickets[](ticketIds.length);

        for (uint256 i = 0; i < ticketIds.length; i++) {
            bytes32 ticketId = ticketIds[i];
            eventTickets[i] = ticketsByTicketId[ticketId];
        }

        return eventTickets;
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
