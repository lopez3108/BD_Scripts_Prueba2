SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5366, cambios en consultas de cash payment y other payment.
CREATE FUNCTION [dbo].[fn_CalculateBillPaymentInitialBalance](
@AgencyId   INT,
@ProviderId INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
--ESTADO DELETE OTHER Y CASH
DECLARE @PaymentOthersStatusId INT ;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')

    RETURN ((

-- Initial balance
ISNULL((SELECT TOP 1 InitialBalance 
FROM BillPaymentxAgencyInitialBalances 
WHERE AgencyId = @AgencyId AND ProviderId = @providerId),0)

-- Daily
- ISNULL(
(
SELECT  SUM(dbo.BillPayments.USD)
FROM            dbo.Daily  INNER JOIN
dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId INNER JOIN
                         dbo.BillPayments ON dbo.Daily.AgencyId = dbo.BillPayments.AgencyId
						 AND CAST(billpayments.CreationDate as date) = CAST(daily.CreationDate as date) AND
						 dbo.Cashiers.UserId = billpayments.CreatedBy
						 WHERE dbo.Daily.AgencyId = @AgencyId and 
						 CAST(dbo.Daily.CreationDate as date) < cast(@EndDate as DATE) and
						 dbo.BillPayments.ProviderId = @ProviderId)
,0)

-- Conciliation bill payment debit

+ ISNULL((SELECT  SUM(Usd)
FROM            dbo.ConciliationBillPayments
WHERE IsCredit = 0 AND
AgencyId = @AgencyId AND
ProviderId = @ProviderId AND
CAST([Date] as date) < cast(@EndDate as DATE)),0)

-- Conciliation bill payment credit

- ISNULL((SELECT  SUM(Usd)
FROM            dbo.ConciliationBillPayments
WHERE IsCredit = 1 AND
AgencyId = @AgencyId AND
ProviderId = @ProviderId AND
CAST([Date] as date) < cast(@EndDate as DATE)),0)

))

-- Payment cash

+ ISNULL(
(SELECT  SUM(USD)
FROM            dbo.PaymentCash
WHERE (DeletedOn is null AND DeletedBy IS NULL AND Status != @PaymentOthersStatusId) AND
AgencyId = @AgencyId AND
ProviderId = @ProviderId AND
CAST(dbo.PaymentCash.Date as date) < cast(@EndDate as DATE))
,0)

-- Payment other (credit)
- ISNULL(
(SELECT  SUM(USD)
FROM            dbo.PaymentOthers
WHERE (DeletedOn is null AND DeletedBy IS NULL AND PaymentOtherStatusId != @PaymentOthersStatusId) AND 
AgencyId = @AgencyId AND
ProviderId = @ProviderId AND
IsDebit = 0 AND
CAST(dbo.PaymentOthers.Date as date) < cast(@EndDate as DATE))
,0)

-- Payment other (debit)
+ ISNULL(
(SELECT  SUM(USD)
FROM            dbo.PaymentOthers
WHERE (DeletedOn is null AND DeletedBy IS NULL AND PaymentOtherStatusId != @PaymentOthersStatusId) AND 
AgencyId = @AgencyId AND
ProviderId = @ProviderId AND
IsDebit = 1 AND
CAST(dbo.PaymentOthers.Date as date) < cast(@EndDate as DATE))
,0)

-- Checks
- ISNULL(
(SELECT  SUM(Usd)
FROM            dbo.PaymentChecksAgentToAgent
WHERE 
ToAgency = @AgencyId AND
ProviderId = @ProviderId AND
CAST(dbo.PaymentChecksAgentToAgent.Date as date) < cast(@EndDate as DATE))
,0)

-- Checks fee
+ ISNULL(
(SELECT  SUM(Fee)
FROM            dbo.PaymentChecksAgentToAgent
WHERE 
Fee > 0 AND
ToAgency = @AgencyId AND
ProviderId = @ProviderId AND
CAST(dbo.PaymentChecksAgentToAgent.Date as date) < cast(@EndDate as DATE))
,0)

-- Payments checks
- ISNULL(
(
SELECT 
SUM(Usd)
FROM            dbo.PaymentChecks pc INNER JOIN
                         dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE 
CAST([Date] as DATE) < CAST(@EndDate as DATE) AND
pc.AgencyId = @AgencyId AND
pc.providerId = @ProviderId)
,0)

-- Payments checks fee
+ ISNULL(
(
SELECT 
SUM(Fee)
FROM            dbo.PaymentChecks pc INNER JOIN
                         dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE 
CAST([Date] as DATE) < CAST(@EndDate as DATE) AND
pc.AgencyId = @AgencyId AND
pc.providerId = @ProviderId AND
Fee > 0)
,0)

-- Commission payment - Adjustment
- ISNULL(

(SELECT SUM(Usd)
FROM            dbo.ProviderCommissionPayments INNER JOIN 
ProviderCommissionPaymentTypes pt ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
WHERE 
dbo.ProviderCommissionPayments.AgencyId = @AgencyId AND
dbo.ProviderCommissionPayments.ProviderId = @ProviderId AND
CAST(dbo.ProviderCommissionPayments.CreationDate as date) < cast(@EndDate as DATE) AND
pt.Code = 'CODE04')

,0)
-- Payments cash to (Provider)
- ISNULL(
(
SELECT 
SUM(pc.Usd)
FROM            dbo.PaymentCashAgentToAgent pc INNER JOIN
                         dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE 
CAST([Date] as DATE) < CAST(@EndDate as DATE) AND
pc.AgencyId = @AgencyId AND
pc.providerId = @ProviderId)
,0)


END




GO