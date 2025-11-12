SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-24 CB/5972: Added refund counter part
-- 2024-08-07 DJ/5991: Added payment type to deposit refunds
-- 2024-08-15 DJ/5974: Cashier must be able to do Deposit payments

CREATE PROCEDURE [dbo].[sp_GetDepositFinancingPayments]
 (
      @ContractId INT
    )
AS 
	
BEGIN


SELECT        
d.DepositFinancingPaymentsId, 
d.ContractId, 
d.Usd, 
d.CreationDate as CreationDate, 
d.CreatedBy, 
d.AgencyId, 
dbo.Users.Name as CreatedByName,
dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS Agency,
dbo.fn_GetDepositFinancingDueFromDate(d.ContractId, d.CreationDate) as Due,
'DEPOSIT PAYMENT' as Type,
 ('**** ' + b.AccountNumber + ' ' +  '(' + ba.Name + ')') AS BankAccountName,
 '' as CheckNumber,
 CASE 
 WHEN d.Cash IS NOT NULL AND d.Cash > 0 THEN
 'CASH' 
 WHEN d.BankAccountId IS NOT NULL THEN
 'BANK DEPOSIT' 
 WHEN d.CardPayment = CAST(1 as BIT) THEN
 'CARD PAYMENT' END as PaymentType
FROM            dbo.DepositFinancingPayments d INNER JOIN
                         dbo.Users ON d.CreatedBy = dbo.Users.UserId LEFT OUTER JOIN
                         dbo.Agencies ON d.AgencyId = dbo.Agencies.AgencyId
						 LEFT JOIN dbo.BankAccounts b ON b.BankAccountId = d.BankAccountId
						 LEFT JOIN dbo.Bank ba ON ba.BankId = b.BankId
						 WHERE ContractId = @ContractId
						 
						
						UNION ALL --5972

  SELECT
  0 as DepositFinancingPaymentsId,
    c.ContractId
   ,ISNULL(c.RefundUsd, 0) AS Usd
   ,c.RefundDate as CreationDate
   ,c.RefundBy AS CreatedBy
   ,c.AgencyRefundId as AgencyId
   ,u.Name as CreatedByName
   ,a.Code + ' - ' + a.Name AS Agency
   ,dbo.fn_GetDepositFinancingDueFromDate(c.ContractId, c.RefundDate) as Due --5969
   ,'DEPOSIT REFUND' as Type
 ,('**** ' + b.AccountNumber + ' ' +  '(' + ba.Name + ')') AS BankAccountName
 ,c.DepositRefundCheckNumber as CheckNumber
 ,CASE WHEN c.DepositRefundCheckNumber IS NOT NULL THEN
 'CHECK' WHEN c.DepositRefundCheckNumber IS NULL AND c.DepositRefundBankAccountId IS NOT NULL THEN
 'BANK DEPOSIT' ELSE
 'CASH' END AS PaymentType
 FROM Contract c
  INNER JOIN Users u
    ON u.UserId = c.RefundBy
  left JOIN Agencies a
    ON c.AgencyRefundId = a.AgencyId
      LEFT JOIN dbo.BankAccounts b ON b.BankAccountId = c.DepositRefundBankAccountId
						 LEFT JOIN dbo.Bank ba ON ba.BankId = b.BankId
  WHERE c.ContractId = @ContractId
  AND c.RefundDate IS NOT NULL
  ORDER BY CreationDate ASC

	END
GO