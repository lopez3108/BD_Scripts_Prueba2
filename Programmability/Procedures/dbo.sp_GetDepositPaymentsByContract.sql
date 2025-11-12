SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-23 DJ/5969: Column Due (Balance) missing, added refund counter part
-- 2024-07-23 CB/5972: Added refund counter part
-- 2024-08-07 DJ/5991: Added payment type to deposit refunds
 --8/09/2024 3:15 p. m. JF/6048: Varios ajustes 
-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT
-- 2025-07-14 JF/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT


CREATE PROCEDURE [dbo].[sp_GetDepositPaymentsByContract] (@ContractId INT,
@Date DATETIME)
AS

BEGIN
  SELECT
    dfp.ContractId
      ,dfp.AgencyId
   ,ISNULL(dfp.Usd, 0) AS Usd
   ,ISNULL(dfp.Cash, 0) AS Cash
   ,dfp.CreationDate
   ,u.Name AS CreatedByName
   ,a.Code + '-' + a.Name AgencyCode
   ,dfp.CardPayment
   ,ISNULL(dfp.CardPaymentFee, 0) AS CardPaymentFee
   ,'DEPOSIT PAYMENT' AS Type
   ,ISNULL(dfp.Usd, 0) + ISNULL(dfp.CardPaymentFee, 0) AS Paid,

 ba1.AccountNumber AS AccountNumber,

			   dbo.fn_GetDepositFinancingDueFromDate(dfp.ContractId, dfp.CreationDate) as Due, --5969
 ('**** ' + ba1.AccountNumber + ' ' +  '(' + ba.Name + ')') AS BankAccountName,
 null as CheckNumber,
 CASE 
 WHEN dfp.Cash IS NOT NULL AND dfp.Cash > 0 THEN
 'CASH' 
 WHEN dfp.BankAccountId IS NOT NULL THEN
 'ACH' 
 WHEN dfp.CardPayment = CAST(1 as BIT) THEN
 'CARD PAYMENT' END as PaymentType,
 dfp.AchDate
 FROM DepositFinancingPayments dfp
  INNER JOIN Users u
    ON u.UserId = dfp.CreatedBy
  left JOIN Agencies a
    ON dfp.AgencyId = a.AgencyId
     LEFT JOIN BankAccounts ba1  ON dfp.BankAccountId = ba1.BankAccountId
	 LEFT JOIN dbo.Bank ba ON ba.BankId = ba1.BankId
  WHERE dfp.ContractId = @ContractId

  UNION ALL --5972

  SELECT
    c.ContractId
      ,c.AgencyRefundId
   ,ISNULL(c.RefundUsd, 0) AS Usd
   ,ISNULL(0, 0) AS Cash
   ,c.RefundDate as CreationDate
   ,u.Name AS CreatedBy
   ,a.Code + '-' + a.Name AgencyCode
   ,0
   ,ISNULL(0, 0) AS CardPaymentFee
   ,'DEPOSIT REFUND' AS Type
   ,ISNULL(c.RefundUsd, 0) AS Paid,
   NULL as AccountNumber,
			   dbo.fn_GetDepositFinancingDueFromDate(c.ContractId, c.RefundDate) as Due --5969
			   ,('**** ' + b.AccountNumber + ' ' +  '(' + ba.Name + ')') AS BankAccountName
 ,c.DepositRefundCheckNumber as CheckNumber
 ,CASE WHEN c.DepositRefundCheckNumber IS NOT NULL THEN
 'CHECK' WHEN c.DepositRefundCheckNumber IS NULL AND c.DepositRefundBankAccountId IS NOT NULL THEN
 'ACH' ELSE
 'CASH' END AS PaymentType,
 c.AchDate
 FROM Contract c
  INNER JOIN Users u
    ON u.UserId = c.RefundBy
  left JOIN Agencies a
    ON c.AgencyRefundId = a.AgencyId
     LEFT JOIN dbo.BankAccounts b ON b.BankAccountId = c.DepositRefundBankAccountId
						 LEFT JOIN dbo.Bank ba ON ba.BankId = b.BankId
  WHERE c.ContractId = @ContractId
  AND c.RefundDate IS NOT NULL
ORDER BY dfp.CreationDate ASC
END


GO