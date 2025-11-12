SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMoneyTransferAgencyInitialBalance] @ProviderId INT = NULL
AS
BEGIN
  SELECT
    a.AgencyId
   ,a.Code + ' - ' + a.Name AS Agency
   ,ISNULL(InitialBalance, 0) AS InitialBalance,
    ISNULL(InitialBalance, 0)  AS InitialBalanceSaved,
   cast(ConfigurationSavedDate as date) AS ConfigurationSavedDate,
     LastUpdatedOn,
     mt.CreatedBy,
 u.Name AS CreatedByName,
 ProviderId
 FROM dbo.Agencies a  
  LEFT JOIN MoneyTransferxAgencyInitialBalances mt 
    ON a.AgencyId = mt.AgencyId AND (mt.ProviderId = @ProviderId
        OR ProviderId IS NULL)
  left JOIN  Users u
    ON u.UserId =  mt.CreatedBy
     
  WHERE a.IsActive = 1 
END;






GO