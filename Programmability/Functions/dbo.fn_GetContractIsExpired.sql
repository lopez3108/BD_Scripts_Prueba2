SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE   FUNCTION [dbo].[fn_GetContractIsExpired] (@ContractId INT,
@Date DATETIME)
RETURNS BIT
AS
BEGIN

	DECLARE @contractDate DATETIME
	SET @contractDate = (SELECT TOP 1
			EndDate
		FROM Contract
		WHERE ContractId = @ContractId)

	DECLARE @contractStatus INT
	SET @contractStatus = (SELECT TOP 1
			Status
		FROM Contract
		WHERE ContractId = @ContractId)

	DECLARE @statusCode VARCHAR(5)
	SET @statusCode = (SELECT TOP 1
			Code
		FROM ContractStatus
		WHERE ContractStatusId = @contractStatus)

	DECLARE @result BIT

	IF (CAST(@Date AS DATE) > CAST(@contractDate AS DATE)
		AND @statusCode <> 'C02') OR  (@statusCode <> 'C02' AND DATEDIFF(DAY, CAST(@Date AS DATE), @contractDate ) <= 30)  
		                                

	BEGIN

		SET @result = CAST(1 AS BIT)

	END

	ELSE
	BEGIN

		SET @result = CAST(0 AS BIT)

	END

	RETURN @result


END
GO