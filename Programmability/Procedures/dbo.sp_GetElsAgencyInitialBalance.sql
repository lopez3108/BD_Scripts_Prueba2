SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetElsAgencyInitialBalance] @ProviderId INT = NULL
AS
BEGIN
  SELECT
    a.AgencyId
   ,a.Code + ' - ' + a.Name AS Agency
   ,ISNULL(InitialBalance, 0) AS InitialBalance,
    ISNULL(InitialBalance, 0)  AS InitialBalanceSaved,
    cast(ConfigurationSavedDate as date) AS ConfigurationSavedDate,
   ProviderId
   ,LastUpdatedOn,
  mt.CreatedBy
   ,u.Name AS CreatedByName
  FROM ElsxAgencyInitialBalances mt
  INNER JOIN  dbo.Agencies a 
    ON a.AgencyId = mt.AgencyId
  left JOIN Users u
    ON u.UserId  = mt.CreatedBy
    
  WHERE a.IsActive = 1 AND mt.ProviderId = @ProviderId
        OR ProviderId IS NULL
END;



GO