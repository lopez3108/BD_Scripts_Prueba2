SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetBillPaymentAgencyInitialBalance] @ProviderId INT = NULL
AS
BEGIN


  SELECT
    a.AgencyId
   ,a.Code + ' - ' + a.Name AS Agency
   ,ISNULL(InitialBalance, 0) AS InitialBalance,
    ISNULL(InitialBalance, 0)  AS InitialBalanceSaved
   , ProviderId,
       cast(ConfigurationSavedDate as date) AS ConfigurationSavedDate,
       LastUpdatedOn,
       bp.CreatedBy,
     u.Name AS CreatedByName
  FROM BillPaymentxAgencyInitialBalances bp 
  INNER JOIN dbo.Agencies a
    ON a.AgencyId = bp.AgencyId
  left JOIN Users u
    ON u.UserId =  bp.CreatedBy
     

  WHERE a.IsActive = 1  AND (bp.ProviderId = @ProviderId
        OR ProviderId IS NULL);
END;



GO