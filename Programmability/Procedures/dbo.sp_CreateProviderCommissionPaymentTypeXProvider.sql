SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateProviderCommissionPaymentTypeXProvider]

@ProviderId INT,
@ProviderCommissionPaymentTypeId INT,
@IsCommissionForex BIT = NULL
AS 

BEGIN

INSERT INTO [dbo].[CommissionPaymentTypesXProviders]
           ([ProviderId]
           ,[ProviderCommissionPaymentTypeId]
           ,IsCommissionForex)
     VALUES
           (@ProviderId
           ,@ProviderCommissionPaymentTypeId
           ,@IsCommissionForex)

		   SELECT @@IDENTITY


	END

GO