SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetDepositFinancingDueFromDate](
@ContractId   INT,
@Date   DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN

		declare @paid decimal(18,2)
		set @paid = (SELECT SUM(Usd) FROM DepositFinancingPayments 
		WHERE ContractId = @ContractId AND
		CAST(CreationDate as DATETIME) <= CAST(@Date as DATETIME))

		declare @deposit decimal(18,2)
		set @deposit = (SELECT TOP 1 DownPayment FROM Contract WHERE ContractId = @ContractId)

		RETURN @deposit - @paid

     END;
GO