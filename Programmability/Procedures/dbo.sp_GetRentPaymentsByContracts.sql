SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-05-12 DJ/6499: Crear nuevo Quick access para los Tenants que esten en Rent due
-- 2025-08-10 DJ/6708: El campo Fee due debe ser calculado con ACH date en vez de fecha actual cuando se ingresa pago tipo ACH

CREATE PROCEDURE [dbo].[sp_GetRentPaymentsByContracts] (@ContractsIds VARCHAR(MAX),
@Date DATETIME)
AS

BEGIN


  SELECT
    r.RentPaymentId
   ,r.ContractId
   ,r.Usd
   ,r.CreationDate
   ,''
   ,dbo.Users.UserId
   ,dbo.Users.Name AS CreatedBy
   ,r.AgencyId
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS Agency
   ,0
   ,ISNULL(r.FeeDue, 0) AS FeeDue
   ,r.CardPayment
   ,r.CardPaymentFee
   ,r.Cash
   ,CASE
      WHEN r.Cash > 0 THEN 'CASH'
      WHEN CardPayment = 1 THEN 'CARD PAYMENT'
      ELSE 'BANK ACCOUNT'
    END AS PaymentType
   ,ba.AccountNumber AS BankAccount
   ,r.UsdPayment
   ,r.FeeDuePending
   ,r.RentPending
   ,r.InitialBalance
   ,r.FinalBalance
   ,ISNULL(r.MoveInFee, 0) AS MoveInFee
   , --5969
    r.AchDate
    ,r.IsCredit
  FROM dbo.RentPayments r
  LEFT JOIN dbo.Agencies
    ON r.AgencyId = dbo.Agencies.AgencyId
  INNER JOIN dbo.Users
    ON r.CreatedBy = dbo.Users.UserId
  LEFT JOIN dbo.BankAccounts ba
    ON ba.BankAccountId = r.BankAccountId
  INNER JOIN dbo.Contract c
    ON r.ContractId = c.ContractId
  WHERE (r.ContractId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ContractsIds))
  )
  ORDER BY r.CreationDate





END



GO