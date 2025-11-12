SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
CREATE FUNCTION [dbo].[fn_GetContractCanEdit] 
(
	@ContractId int,
	@Date DATETIME,
	@UserId INT
)
RETURNS BIT
AS
BEGIN

DECLARE @result BIT, @contractDate DATETIME, @contractStatusCode VARCHAR(5),@creationUserId INT

SET @creationUserId = (SELECT TOP 1 CreatedBy FROM Contract WHERE ContractId = @ContractId)

SET @contractDate = (SELECT TOP 1 CreationDate FROM Contract WHERE ContractId = @ContractId)

SET @contractStatusCode = (SELECT TOP 1 cs.Code FROM ContractStatus cs INNER JOIN Contract c on c.Status = cs.ContractStatusId WHERE c.ContractId = @ContractId)

IF( (CAST(@Date as DATE) <> CAST(@contractDate as DATE)) OR 
			   (CAST([dbo].[fn_GetCheckContractPayments](@ContractId) as BIT) = CAST(1 as BIT)) OR
			   @creationUserId <> @UserId OR
			   @contractStatusCode = 'C02') 
			   BEGIN
			   SET @result = CAST(0 as BIT)
			   END
			   ELSE
			   BEGIN
			   SET @result = CAST(1 as BIT) 
			   END

RETURN @result

END

GO