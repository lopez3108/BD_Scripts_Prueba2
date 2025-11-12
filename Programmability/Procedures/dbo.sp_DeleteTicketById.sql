SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteTicketById](@TicketId INT)
AS
     BEGIN
	   DELETE NotesXTicket WHERE TicketId = @TicketId;
         DELETE Tickets
         WHERE TicketId = @TicketId;
        
     END;
GO