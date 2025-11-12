SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-07-22 DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_GetTitlesFromTickets] 
@Telephone VARCHAR(max)
AS
BEGIN

  WITH Ranked AS (
    SELECT 
        t.Telephone,
        t.PlateNumber,
        t.Name AS Name,
        RIGHT(t.Name, CHARINDEX(' ', REVERSE(t.Name) + ' ') - 1) AS LastName,
        ROW_NUMBER() OVER (
            PARTITION BY t.Telephone, t.Name 
            ORDER BY t.PlateNumber
        ) AS rn
    FROM dbo.Titles t
	WHERE (t.PlateNumber IS NOT NULL AND t.PlateNumber <> '') AND
	--t.ClientTelephone = '3017165587' OR  t.ClientTelephone = '2222222222'
(t.Telephone IN (SELECT
      item
    FROM dbo.FN_ListToTableString(@Telephone))
  OR (@Telephone = ''))
)

SELECT Telephone, PlateNumber, Name, LastName
FROM Ranked
WHERE rn = 1;


END;

GO