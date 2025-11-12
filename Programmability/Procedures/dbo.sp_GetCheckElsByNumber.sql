SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckElsByNumber] @ProviderCommissionPaymentId INT
AS
     BEGIN
         SELECT 
			*
         FROM dbo.ProviderCommissionPayments pcp
         WHERE pcp.ProviderCommissionPaymentId = @ProviderCommissionPaymentId;
     END;
GO