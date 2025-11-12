SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-16 DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_GetTicketsTitlesClientsCount] 
AS
BEGIN

DECLARE @ticketsCount INT
 
 SET @ticketsCount = (SELECT COUNT(DISTINCT t.ClientTelephone)
  FROM dbo.Tickets t )
  
  DECLARE @titlesCount INT
 
 SET @titlesCount = (SELECT COUNT(DISTINCT t.Telephone)
  FROM dbo.Titles t 
  WHERE t.Telephone NOT IN (SELECT c.ClientTelephone FROM dbo.Tickets c))

  SELECT @ticketsCount + @titlesCount



END;

GO