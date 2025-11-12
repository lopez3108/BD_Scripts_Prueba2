SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteProviderCommissionPaymentTypeXProvider]

@ProviderId INT,
@IsCommissionForex BIT = NULL
AS 

BEGIN

DELETE [dbo].[CommissionPaymentTypesXProviders] WHERE ProviderId = @ProviderId AND (IsCommissionForex = @IsCommissionForex OR @IsCommissionForex IS NULL)

SELECT @ProviderId

	END

GO