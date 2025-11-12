SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-30 DJ/5979: Deposit refund fee calculation

CREATE FUNCTION [dbo].[fn_GetDepositRefundTotal](
@ContractId   INT,
@EndDate   DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN

		DECLARE @daysLived INT, @dateStart DATETIME, @depositRefundFee DECIMAL(18,2),  @feePerDay DECIMAL(18,4),
		@feeGenerated DECIMAL(18,4), @feeApplied DECIMAL(18,4) = 0, @paid decimal(18,2), @deposit decimal(18,2),
		@contractClosed BIT

		SET @paid = (SELECT SUM(Usd) FROM DepositFinancingPayments
		WHERE ContractId = @ContractId)

		SET @depositRefundFee = (SELECT TOP 1 c.DepositRefundFee FROM dbo.Contract c WHERE c.ContractId = @ContractId)

		IF(@paid <> 0 AND @depositRefundFee <> 0)
		BEGIN

		SET @EndDate = (SELECT TOP 1 CASE WHEN c.ClosedDate IS NOT NULL THEN
		c.ClosedDate ELSE
		@EndDate END
		FROM dbo.Contract c WHERE ContractId = @ContractId)

		SET @dateStart = (SELECT TOP 1 c.StartDate FROM dbo.Contract c WHERE c.ContractId = @ContractId)
		SET @daysLived = (SELECT DATEDIFF(day,CAST(@dateStart as DATE), CAST(@EndDate as DATE)))
		SET @feePerDay = (@depositRefundFee / 365)
		SET @feeGenerated = @daysLived * @feePerDay
		SET @feeApplied = (@paid * @feeGenerated) / 100

		END

		RETURN @feeApplied

     END;
GO