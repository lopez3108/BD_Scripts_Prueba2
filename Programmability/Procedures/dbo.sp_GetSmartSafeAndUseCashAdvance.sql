SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created: FELIPE
--CReated: 17-01-2024
--Task 5550
CREATE PROCEDURE [dbo].[sp_GetSmartSafeAndUseCashAdvance] @AgencyId int = NULL
AS
BEGIN
  SELECT 
      p.ProviderId
     ,p.Active    
     ,ISNULL(p.UseSmartSafeDeposit, 0) UseSmartSafeDeposit
     ,ISNULL(p.UseCashAdvanceOrBack, 0) UseCashAdvanceOrBack

FROM Providers p
  INNER JOIN ProviderTypes pt
    ON p.ProviderTypeId = pt.ProviderTypeId
INNER JOIN MoneyTransferxAgencyNumbers mt
    ON p.ProviderId = mt.ProviderId
      AND mt.AgencyId = @AgencyId
WHERE pt.Code = 'C02'--Money transfer

END;



GO