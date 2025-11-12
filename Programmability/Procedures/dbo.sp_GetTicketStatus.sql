SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetTicketStatus] @TicketNumber VARCHAR(30),@AgencyId INT
AS
  SELECT

   ts.Description  

  FROM Tickets t
  INNER JOIN TicketStatus ts ON ts.TicketStatusId = t.TicketStatusId 
  WHERE t.TicketNumber = @TicketNumber AND t.AgencyId = @AgencyId
 
GO