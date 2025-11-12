SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-07-23 DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_GetTicketsExistingByTicketNumber] 
@TicketNumber VARCHAR(max)
AS
BEGIN

SELECT t.TicketNumber FROM dbo.Tickets t
WHERE
(t.TicketNumber IN (SELECT
      item
    FROM dbo.FN_ListToTableString(@TicketNumber))
  OR (@TicketNumber = ''))




END;

GO