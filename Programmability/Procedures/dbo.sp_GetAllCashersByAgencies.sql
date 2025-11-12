SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCashersByAgencies] @AgenciesId VARCHAR(500) = NULL
AS


BEGIN

  SELECT DISTINCT
    u.Name,
	c.CashierId
  FROM AgenciesxUser au 
   JOIN Cashiers c ON au.UserId = c.UserId 
   join Users u on u.UserId = c.UserId 
 WHERE (au.AgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@AgenciesId))
  OR (@AgenciesId = ''
  OR @AgenciesId IS NULL))
    AND c.IsActive = 1
  order by u.Name asc 
END
GO