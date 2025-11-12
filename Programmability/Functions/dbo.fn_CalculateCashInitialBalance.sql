SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5366, cambios en consultas de cash payment y other payment.
CREATE FUNCTION [dbo].[fn_CalculateCashInitialBalance] (@AgencyId INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
--ESTADO DELETE OTHER Y CASH
DECLARE @PaymentOthersStatusId INT ;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')

  RETURN ((

  -- Closing cash
  ISNULL((SELECT
      SUM(CASE
        WHEN ClosedByCashAdmin IS NULL OR --Cash admin puede ser 0 task 5371
          ClosedByCashAdmin = 0 THEN Cash
        ELSE CashAdmin
      END)
    FROM dbo.Daily
    WHERE CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE)
    AND AgencyId = @AgencyId
    AND (Cash > 0
    OR ClosedByCashAdmin > 0))
  , 0)

  -- Payment cash
  + ISNULL((SELECT
      SUM(
      dbo.PaymentCash.Usd)
    FROM dbo.PaymentCash
    INNER JOIN dbo.Providers
      ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE (DeletedOn is null AND DeletedBy IS NULL AND Status != @PaymentOthersStatusId) AND 
    CAST([Date] AS DATE) < CAST(@EndDate AS DATE)
    AND dbo.PaymentCash.AgencyId = @AgencyId)
  , 0)

  -- Cash agent to agent to
  + ISNULL((SELECT
      SUM(
      dbo.PaymentCashAgentToAgent.USD)
    FROM dbo.PaymentCashAgentToAgent
    INNER JOIN dbo.Agencies AS Agencies_1
      ON dbo.PaymentCashAgentToAgent.AgencyId = Agencies_1.AgencyId
    INNER JOIN dbo.Agencies
      ON dbo.PaymentCashAgentToAgent.FromAgencyId = dbo.Agencies.AgencyId
    INNER JOIN dbo.Providers
      ON dbo.Providers.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
    WHERE CAST([Date] AS DATE) < CAST(@EndDate AS DATE)
    AND dbo.PaymentCashAgentToAgent.FromAgencyId = @AgencyId)
  , 0)

  -- Cash agent to agent to
  + ISNULL((SELECT
      SUM(
      dbo.PaymentOthersAgentToAgent.Usd)
    FROM dbo.PaymentOthersAgentToAgent
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PaymentOthersAgentToAgent.ProviderCommissionPaymentTypeId
    WHERE dbo.PaymentOthersAgentToAgent.ToAgency = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST([Date] AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Cash agent to agent from
  + ISNULL((SELECT
      SUM(
      dbo.PaymentOthersAgentToAgent.Usd)
    FROM dbo.PaymentOthersAgentToAgent
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PaymentOthersAgentToAgent.ProviderCommissionPaymentTypeId
    WHERE dbo.PaymentOthersAgentToAgent.FromAgency = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST([Date] AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Bill taxes
  + ISNULL((SELECT
      SUM(
      dbo.PropertiesBillTaxes.Usd)
    FROM dbo.PropertiesBillTaxes
    INNER JOIN dbo.Properties
      ON dbo.PropertiesBillTaxes.PropertiesId = dbo.Properties.PropertiesId
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId
    WHERE AgencyId = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Bill water

  + ISNULL((SELECT
      SUM(
      dbo.PropertiesBillWater.Usd)
    FROM dbo.PropertiesBillWater
    INNER JOIN dbo.Properties
      ON dbo.PropertiesBillWater.PropertiesId = dbo.Properties.PropertiesId
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId
    WHERE AgencyId = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST(dbo.PropertiesBillWater.CreationDate AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Bill insurance

  + ISNULL((SELECT
      SUM(
      dbo.PropertiesBillInsurance.Usd)
    FROM dbo.PropertiesBillInsurance
    INNER JOIN dbo.Properties
      ON dbo.PropertiesBillInsurance.PropertiesId = dbo.Properties.PropertiesId
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId
    WHERE AgencyId = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST(dbo.PropertiesBillInsurance.CreationDate AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Bill labor
  + ISNULL((SELECT
      SUM(
      dbo.PropertiesBillLabor.Usd)
    FROM dbo.PropertiesBillLabor
    INNER JOIN dbo.Properties
      ON dbo.PropertiesBillLabor.PropertiesId = dbo.Properties.PropertiesId
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId
    WHERE AgencyId = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST(dbo.PropertiesBillLabor.CreationDate AS DATE) < CAST(@EndDate AS DATE))
  , 0)


  -- Bill others
  + ISNULL((SELECT
      SUM(
      CASE
        WHEN IsCredit = 1 THEN dbo.PropertiesBillOthers.Usd
        ELSE (dbo.PropertiesBillOthers.Usd * -1)
      END)
    FROM dbo.PropertiesBillOthers
    INNER JOIN dbo.Properties
      ON dbo.PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId
    INNER JOIN dbo.ProviderCommissionPaymentTypes pc
      ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId
    WHERE AgencyId = @AgencyId
    AND pc.Code = 'CODE01'
    AND CAST(dbo.PropertiesBillOthers.CreationDate AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Closing extra fund
--  + ISNULL((SELECT
--      SUM(
--      dbo.ExtraFund.Usd)
--    FROM dbo.ExtraFund
--    INNER JOIN dbo.Users
--      ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
--    INNER JOIN dbo.UserTypes
--      ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
--    WHERE  UserTypes.Code = 'Admin'
--    AND CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE)
--    AND AgencyId = @AgencyId)
--  , 0)

 --Closing extra fund admin a cajero y cashier to cashier
  + ISNULL((SELECT
      SUM(
      dbo.ExtraFund.Usd)
    FROM dbo.ExtraFund
    INNER JOIN dbo.Users
      ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
    INNER JOIN dbo.UserTypes
      ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
    WHERE((IsCashier = 0
        AND CashAdmin = 0)
        OR (IsCashier = 1))  
    AND CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE)
    AND AgencyId = @AgencyId)
  , 0)

--Closing extra fund cajero a admin 
  + ISNULL((SELECT
      SUM(
      dbo.ExtraFund.Usd)
    FROM dbo.ExtraFund
    INNER JOIN dbo.Users
      ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
    INNER JOIN dbo.UserTypes
      ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
    WHERE CashAdmin = 1
    AND CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE)
    AND AgencyId = @AgencyId)
  , 0)

  -- Cash fund
  + ISNULL((SELECT
      SUM(
      (dbo.CashFundModifications.OldCashFund - dbo.CashFundModifications.NewCashFund))
    FROM dbo.CashFundModifications
    INNER JOIN dbo.Cashiers
      ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
    INNER JOIN dbo.Users
      ON dbo.Cashiers.UserId = dbo.Users.UserId
    WHERE AgencyId = @AgencyId
    AND CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE))
  , 0)

  -- Money distribution
  + ISNULL((SELECT
      SUM(
      (dd.Usd))
   FROM DailyDistribution dd
      INNER JOIN Daily d
        ON d.DailyId = dd.DailyId
      WHERE 
       (CAST(d.CreationDate AS DATE) < CAST(@EndDate AS DATE))
      AND d.AgencyId = @AgencyId),0)
  
  -- Payment bank
  + ISNULL((SELECT
      SUM(
      (dbo.PaymentBanks.Usd))
   FROM dbo.PaymentBanks
      WHERE 
       (CAST([Date] AS DATE) < CAST(@EndDate AS DATE))
      AND dbo.PaymentBanks.AgencyId= @AgencyId),0)

 -- Commission 
  + ISNULL((SELECT
      SUM(
      (c.Usd))
   FROM dbo.ProviderCommissionPayments c
     INNER JOIN dbo.Providers
        ON c.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    INNER JOIN ProviderCommissionPaymentTypes pt
        ON pt.ProviderCommissionPaymentTypeId = c.ProviderCommissionPaymentTypeId
      WHERE (dbo.ProviderTypes.Code != 'C14')
      AND pt.Code ='CODE01' AND
       (CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE))
      AND  c.AgencyId = @AgencyId),0)

-- Other commission
  + ISNULL((SELECT
      SUM(
      (co.Usd))
   FROM dbo.OtherCommissions co
   INNER JOIN ProviderCommissionPayments C
        ON C.ProviderCommissionPaymentId = co.ProviderCommissionPaymentId
     WHERE
       (CAST(CreationDate AS DATE) < CAST(@EndDate AS DATE))
      AND  c.AgencyId = @AgencyId),0)



 -- Payroll
  + ISNULL((SELECT
      SUM(
      (p.TotalPayment))
   FROM dbo.Payrolls p
      WHERE 
       (CAST(p.PaidOn AS DATE) < CAST(@EndDate AS DATE))
      AND p.AgencyId= @AgencyId),0)



  -- Agency initial cash balance
  + ISNULL((SELECT TOP 1
      ISNULL(InitialBalanceCash, 0)
    FROM Agencies
    WHERE AgencyId = @AgencyId)
  , 0)

  ))

END


GO