SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATE Felipe oquendo
--Date: 15-11-2023 task: 5505

CREATE PROCEDURE [dbo].[sp_GetAllCashiersActivesManager]
(
                 @UserId int = NULL
)
AS

  DECLARE @ListAgencyId AS nchar(1000);
  SET @ListAgencyId = (SELECT STRING_AGG(AgencyId, ',')
FROM AgenciesxUser aus
WHERE aus.UserId = @UserId);

  BEGIN

    SELECT u.Name,
    Cashiers.CashierId,
    Cashiers.IsActive,  
    u.UserId 
    FROM Cashiers
         INNER JOIN
         Users u
         ON Cashiers.UserId = u.UserId
         LEFT JOIN
         AgenciesxUser au
         ON u.UserId = au.UserId         
         LEFT JOIN Agencies a ON au.AgencyId = a.AgencyId
    WHERE Cashiers.IsActive = 1 AND
          (a.AgencyId IN (SELECT item
        FROM dbo.FN_ListToTableInt(@ListAgencyId)) OR
          @ListAgencyId IS NULL)
          GROUP BY u.Name, Cashiers.CashierId,Cashiers.IsActive,u.UserId

ORDER BY u.Name 
  END;


GO