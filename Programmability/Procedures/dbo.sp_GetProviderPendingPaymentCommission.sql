SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 30/06/2024 1:01 p. m.
-- Database:    copiaDevtest
-- Description: 5446 ? Ajustes pagos de comisiones según el tipo de pago
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetProviderPendingPaymentCommission] (@ProviderId INT, @ProviderTypeId INT)
AS
BEGIN

  DECLARE @ProviderTypeCode VARCHAR(5);
  SET @ProviderTypeCode = (SELECT TOP 1
      pt.Code
    FROM ProviderTypes pt
    WHERE pt.ProviderTypeId = @ProviderTypeId);

IF (@providerTypeCode = 'C01') BEGIN --Provider type TOP-UP PAYMENTS
 IF ((SELECT
        SUM(ISNULL(B.Commission, 0))
      FROM dbo.BillPayments B
      WHERE B.ProviderId = @ProviderId)
    ) > (SELECT
        SUM(ISNULL(pcp.Usd, 0))
      FROM dbo.ProviderCommissionPayments pcp
      WHERE pcp.ProviderId = @ProviderId)
  BEGIN
    SELECT
      CAST(1 AS BIT) AS HasPendingPaymentCommission

  END
  ELSE
  BEGIN
    SELECT
      CAST(0 AS BIT) AS HasPendingPaymentCommission
  END 
	
END 


END;
GO