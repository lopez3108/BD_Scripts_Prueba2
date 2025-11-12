SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUsersXRight]
@Position INT,
@AgencyId INT
AS
     BEGIN


SELECT DISTINCT * FROM (
SELECT 
r.UserId,
UPPER(u.Name) as [Name]
from RightsxUser r
INNER JOIN dbo.Users u ON u.UserId = r.UserId
INNER JOIN dbo.AgenciesxUser a ON r.UserId = a.UserId
INNER JOIN dbo.Cashiers c ON c.UserId = r.UserId
WHERE SUBSTRING(Rights, @Position, 1) = '1' 
AND a.AgencyId = @AgencyId
AND CAST(c.IsActive AS BIT) = CAST(1 AS BIT)
UNION ALL
SELECT 
u.UserId,
UPPER(u.Name) as [Name]
From Cashiers c
INNER JOIN Users u ON u.UserId = c.UserId
Where (c.IsAdmin = 1 OR c.IsManager = 1) AND CAST(c.IsActive AS BIT) = CAST(1 AS BIT)) q
ORDER BY Name ASC



END;
GO