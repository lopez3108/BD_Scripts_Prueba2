SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-04-23  JF/6447: Permitir editar tickets usd


CREATE PROCEDURE [dbo].[sp_GetTicketStatusById] @TicketId INT
AS
BEGIN
  SELECT
    t.TicketId
   ,t.Usd
   ,CAST(
    CASE
      WHEN ts.Code = 'C00' OR
        ts.Code = 'C03' THEN 0
      ELSE 1
    END AS BIT
    ) AS Disabled

  FROM Tickets t
  INNER JOIN TicketStatus ts
    ON t.TicketStatusId = ts.TicketStatusId
  WHERE t.TicketId = @TicketId;
END;







GO