SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-07-22- DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_GetTicketsFromTitles] 
@Telephone VARCHAR(max)
AS
BEGIN

WITH Ranked AS (
    SELECT 
        t.ClientTelephone AS Telephone,
        t.TicketNumber,
        t.ClientName AS Name,
        RIGHT(t.ClientName, CHARINDEX(' ', REVERSE(t.ClientName) + ' ') - 1) AS LastName,
        ROW_NUMBER() OVER (
            PARTITION BY t.ClientTelephone, t.ClientName 
            ORDER BY t.TicketNumber  -- You can change this to CreatedDate if needed
        ) AS rn
    FROM dbo.Tickets t
	WHERE 
	--t.ClientTelephone = '3017165587' OR  t.ClientTelephone = '2222222222'
(t.ClientTelephone IN (SELECT
      item
    FROM dbo.FN_ListToTableString(@Telephone))
  OR (@Telephone = ''))
)

SELECT Telephone, TicketNumber, Name, LastName
FROM Ranked
WHERE rn = 1;

END

GO