SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-15 DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_GetTitlesClients] 
@Date DATETIME,
@Count INT
AS
BEGIN


WITH TopTelephones AS (
  SELECT DISTINCT TOP (@Count) Telephone
  FROM dbo.Titles t
  WHERE t.PlateNumber IS NOT NULL AND t.PlateNumber <> ''
  ORDER BY Telephone
),
Ranked AS (
  SELECT
    t.Telephone,
    RIGHT(t.Name, CHARINDEX(' ', REVERSE(t.Name) + ' ') - 1) AS LastName,
    t.Name,
    t.PlateNumber,
    ROW_NUMBER() OVER (
      PARTITION BY t.Telephone
      ORDER BY t.PlateNumber  -- or t.CreatedDate DESC, etc.
    ) AS rn
  FROM dbo.Titles t
  JOIN TopTelephones tt ON t.Telephone = tt.Telephone
  WHERE t.PlateNumber IS NOT NULL AND t.PlateNumber <> ''
)
SELECT Telephone, LastName, Name, PlateNumber
FROM Ranked
WHERE rn = 1
ORDER BY Telephone;


END;

GO