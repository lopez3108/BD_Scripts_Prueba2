SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-15 DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_GetTicketsClients] 
@Date DATETIME,
@Count INT,
@Telephone VARCHAR(max)
AS
BEGIN

WITH TopTelephones AS (
    SELECT DISTINCT TOP (@Count) ClientTelephone Telephone
    FROM dbo.Tickets t
    WHERE TicketNumber IS NOT NULL 
	AND (t.ClientTelephone NOT IN (SELECT
      item
    FROM dbo.FN_ListToTableString(@Telephone))
  OR (@Telephone = ''))
    ORDER BY ClientTelephone
),

RankedNames AS (
    SELECT 
        t.ClientTelephone Telephone,
        RIGHT(t.ClientName, CHARINDEX(' ', REVERSE(t.ClientName) + ' ') - 1) AS LastName,
        t.ClientName Name,
        t.TicketNumber,
        ROW_NUMBER() OVER (
            PARTITION BY t.ClientTelephone, t.ClientName
            ORDER BY t.TicketNumber  -- or t.CreatedDate if you want the newest
        ) AS rn
    FROM dbo.Tickets t
    INNER JOIN TopTelephones tt ON t.ClientTelephone = tt.Telephone
    WHERE t.TicketNumber IS NOT NULL
),

FirstPlatesPerName AS (
    SELECT *
    FROM RankedNames
    WHERE rn = 1
)

SELECT Telephone, LastName, Name, TicketNumber
FROM FirstPlatesPerName
ORDER BY Telephone, Name;












WITH TopTelephones AS (
    SELECT DISTINCT TOP (@Count) ClientTelephone Telephone
    FROM dbo.Tickets t
    WHERE t.TicketNumber IS NOT NULL 
	AND (t.ClientTelephone NOT IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@Telephone))
  OR (@Telephone = ''))
    ORDER BY Telephone
),

-- Step 2: Rank each Name within its Telephone
RankedNames AS (
    SELECT 
        t.ClientTelephone Telephone,
        RIGHT(t.ClientName, CHARINDEX(' ', REVERSE(t.ClientName) + ' ') - 1) AS LastName,
        t.ClientName Name,
        t.TicketNumber,
        ROW_NUMBER() OVER (
            PARTITION BY t.ClientTelephone, t.ClientName
            ORDER BY t.TicketNumber  -- or t.CreatedDate if available
        ) AS rn
    FROM dbo.Tickets t
    INNER JOIN TopTelephones tt ON t.ClientTelephone = tt.Telephone
    WHERE t.TicketNumber IS NOT NULL
),

-- Step 3: Get only the first PlateNumber per Name within each Telephone
FirstPlatesPerName AS (
    SELECT *
    FROM RankedNames
    WHERE rn = 1
)

-- Final result
SELECT Telephone, LastName, Name, TicketNumber
FROM FirstPlatesPerName
ORDER BY Telephone, Name;



END;

GO