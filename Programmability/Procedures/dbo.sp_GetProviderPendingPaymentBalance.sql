SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderPendingPaymentBalance](@ProviderId INT)
AS
     BEGIN
        
		IF(EXISTS(SELECT * FROM dbo.fn_GetPendingPaymentBalanceByProvider(@ProviderId)))
		BEGIN

		SELECT CAST(1 as BIT) as HasPendingPaymentBalance


		END
		ELSE
		BEGIN

		SELECT CAST(0 as BIT) as HasPendingPaymentBalance

		END


     END;
GO