SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
CREATE FUNCTION [dbo].[fn_GetCheckContractPayments] 
(
	@ContractId int
)
RETURNS BIT
AS
BEGIN

declare @result BIT

SET @result = CAST(0 as BIT)

IF(EXISTS(SELECT * FROM RentPayments WHERE ContractId = @ContractId) OR
EXISTS(SELECT * FROM DepositFinancingPayments WHERE ContractId = @ContractId))
BEGIN

SET @result = CAST(1 as BIT)

END

RETURN @result

END

GO