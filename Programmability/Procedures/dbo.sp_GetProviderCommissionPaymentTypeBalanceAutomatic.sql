SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderCommissionPaymentTypeBalanceAutomatic]
AS
     BEGIN
         SELECT 
		 p.ProviderCommissionPaymentTypeId,
                p.Code,
                p.Description
         FROM dbo.ProviderCommissionPaymentTypes p
         WHERE p.Code = 'CODE05'
     END;
GO