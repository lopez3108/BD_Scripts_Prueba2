SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CalculateTotalPaymentCheckElsAgenttoagent] (@PaymentChecksAgentToAgentId INT)
AS
BEGIN

  DECLARE @total DECIMAL(18, 2)

  DECLARE @totalCheckEls DECIMAL(18, 2)
  SET @totalCheckEls = (SELECT
      ISNULL(SUM(ce.Amount),0)
    FROM ChecksEls ce
    WHERE ce.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId)

  DECLARE @totalReturnPayment DECIMAL(18, 2)
  SET @totalReturnPayment = (SELECT
      ISNULL(SUM(rp.Usd),0)
    FROM ReturnPayments rp
    WHERE rp.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId)

  DECLARE @totalProviderCommision DECIMAL(18, 2)
  SET @totalProviderCommision = (SELECT
      ISNULL(SUM(rp.Usd),0)
    FROM ProviderCommissionPayments rp
    WHERE rp.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId)

  DECLARE @totalOtherCommision DECIMAL(18, 2)
  SET @totalOtherCommision = (SELECT
      ISNULL(SUM(o.Usd),0)
    FROM [OtherCommissions] o
    WHERE o.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId)

  SET @total = @totalCheckEls + @totalReturnPayment + @totalProviderCommision + @totalOtherCommision;

  UPDATE PaymentChecksAgentToAgent
  SET Usd = @total
  WHERE PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId


END
GO