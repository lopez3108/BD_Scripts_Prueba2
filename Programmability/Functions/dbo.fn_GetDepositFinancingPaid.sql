SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetDepositFinancingPaid] (@ContractId INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

  DECLARE @card DECIMAL(18, 2)
  DECLARE @paid DECIMAL(18, 2)
  SET @card = (SELECT
      ISNULL(SUM(CardPaymentFee), 0)
    FROM DepositFinancingPayments
    WHERE ContractId = @ContractId)
  SET @paid = (SELECT
      ISNULL(SUM(USD), 0)
    FROM DepositFinancingPayments
    WHERE ContractId = @ContractId);

  RETURN
  (
  @paid

  );
END;

GO