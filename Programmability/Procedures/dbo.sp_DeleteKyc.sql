SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteKyc]
	@ProviderId INT,
	@OrderNumber VARCHAR(15)
AS
BEGIN

	DELETE Kyc WHERE ProviderId = @ProviderId AND OrderNumber = @OrderNumber

	SELECT 1
END
GO