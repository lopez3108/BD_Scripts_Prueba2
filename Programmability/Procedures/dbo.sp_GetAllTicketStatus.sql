SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTicketStatus] @Code VARCHAR(200) = NULL
AS
     BEGIN
         SELECT *
         FROM TicketStatus
         WHERE TicketStatus.Code IN(@Code)
         OR @Code IS NULL
         OR @Code = ''
         ORDER BY Sort ASC;
     END;
GO