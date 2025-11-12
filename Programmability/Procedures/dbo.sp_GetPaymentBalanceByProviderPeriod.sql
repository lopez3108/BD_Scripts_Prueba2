SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentBalanceByProviderPeriod] @AgencyId   INT,
                                             @ProviderId INT    ,
											 @Year     INT,
											 @Month     INT
AS
     BEGIN
       SELECT   ISNULL((SELECT 
                dbo.PaymentBalance.Commission
         FROM dbo.PaymentBalance
         WHERE dbo.PaymentBalance.AgencyId = @AgencyId
               AND dbo.PaymentBalance.ProviderId = @ProviderId
			   AND (@Year is NULL OR @Year = dbo.PaymentBalance.Year)
			   AND (@Month is NULL OR @Month = dbo.PaymentBalance.Month)
			   AND (dbo.PaymentBalance.DeletedBy IS NULL AND dbo.PaymentBalance.DeletedOn IS NULL)
			   ),0) as Usd
			   
     END;
GO