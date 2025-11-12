SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Edit by JT 16-04-2024 task 5806
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- 2024-09-24 DJ/6020: Added insurance ACH operations
-- 2024-10-26 JT/6114: Insurance payments only show in the agency filtered
-- 2024-10-26 JT/6136: Ajuste reportes - mostrar código de agencia para las ventas
-- 2025-06-24 JF/6623: Rerpote cash > bank deposit mostrar los  últimos 4 dígitos de la cuenta
-- 2025-08-31 JF/6733: Rerpote cash > The daily cash is affected by the admin cash.

CREATE FUNCTION [dbo].[FN_GenerateCashReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Type INT = NULL)
RETURNS @Result TABLE (

  [Index] INT
 ,[Type] VARCHAR(50)
 ,CreationDate DATETIME
 ,[Description] VARCHAR(1000)
 ,Credit DECIMAL(18, 2)
 ,Debit DECIMAL(18, 2)
 ,AccountNumberBank VARCHAR(60)
 ,Balance DECIMAL(18, 2)

)
AS
BEGIN

  --ESTADO DELETE OTHER Y CASH
  DECLARE @PaymentOthersStatusId INT;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')

  --Closing cash --  -- Money Distribution --este código se comenta en la tarea 6733 debido a que el cash available(daily) no se contabiliza en el reporte cash

  IF (@Type IS NULL
    OR @Type = 1)
  BEGIN
    INSERT INTO @Result
      SELECT
        1
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,0 AS Credit
       ,SUM(ISNULL(t.Usd, 0)) AS Debit
       ,NULL
       ,SUM(ISNULL(t.Usd, 0))
      FROM (SELECT
          'CLOSING CASH' AS Type
         ,CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate
         ,'CLOSING CASH' AS Description
         ,(CASE
            WHEN dbo.Daily.ClosedByCashAdmin IS NULL OR
              dbo.Daily.ClosedByCashAdmin = 0 THEN ISNULL(dbo.Daily.Cash, 0)
            ELSE ISNULL(dbo.Daily.CashAdmin, 0) + ISNULL((SELECT
                  SUM(dd.Usd)
                FROM DailyDistribution dd
                WHERE dd.DailyId = dbo.Daily.DailyId) --The daily cash is affected by the admin cash. In this case we sum the distributed money and cash admin as a final cash daily
              , 0)
          END)

          Usd
        FROM dbo.Daily
        WHERE dbo.Daily.CreationDate >= CAST(@FromDate AS DATE)
        AND dbo.Daily.CreationDate < DATEADD(DAY, 1, CAST(@ToDate AS DATE))
        AND AgencyId = @AgencyId
        AND (dbo.Daily.Cash > 0
        OR (ClosedByCashAdmin > 0
        AND CashAdmin > 0))) t --Task 5371 el cash admin permite 0 como valor
        WHERE t.Usd > 0
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;

  END;

  -- Payment cash
  IF (@Type IS NULL
    OR @Type = 2)
  BEGIN
    INSERT INTO @Result
      SELECT
        2
       ,'PAYMENT CASH' AS Type
       ,dbo.PaymentCash.Date
       ,dbo.Providers.Name +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ' - ' + ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = dbo.PaymentCash.AgencyId
              AND mt.ProviderId = dbo.PaymentCash.ProviderId)
            , 'NUMBER NOT REGISTERED')
          ELSE ''
        END AS Description
       ,dbo.PaymentCash.USD AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - dbo.PaymentCash.USD
      FROM dbo.PaymentCash
      INNER JOIN dbo.Providers
        ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      WHERE (DeletedOn IS NULL
      AND DeletedBy IS NULL
      AND Status <> @PaymentOthersStatusId)
      AND CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.PaymentCash.AgencyId = @AgencyId;

  END;

  -- Cash agent to agent (from agency)
  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN
    INSERT INTO @Result
      SELECT
        3
       ,'CASH (AGENCY TO AGENCY) PROVIDER' AS Type
       ,dbo.PaymentCashAgentToAgent.[Date]
       ,dbo.Agencies.Code + ' TO ' + Agencies_1.Code + ' - ' + dbo.Providers.Name +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ' - ' + ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = dbo.PaymentCashAgentToAgent.AgencyId
              AND mt.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId)
            , 'NOT REGISTERED')
          ELSE ''
        END AS Description
       ,dbo.PaymentCashAgentToAgent.USD AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - dbo.PaymentCashAgentToAgent.USD
      FROM dbo.PaymentCashAgentToAgent
      INNER JOIN dbo.Agencies AS Agencies_1
        ON dbo.PaymentCashAgentToAgent.AgencyId = Agencies_1.AgencyId
      INNER JOIN dbo.Agencies
        ON dbo.PaymentCashAgentToAgent.FromAgencyId = dbo.Agencies.AgencyId
      INNER JOIN dbo.Providers
        ON dbo.Providers.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
      WHERE CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.PaymentCashAgentToAgent.FromAgencyId = @AgencyId
      AND dbo.PaymentCashAgentToAgent.DeletedOn IS NULL;

  END;

  --   -- Cash agent to agent (To agency)
  --  IF (@Type IS NULL
  --    OR @Type = 3)
  --  BEGIN
  --    INSERT INTO #Temp
  --      SELECT
  --        2
  --       ,4
  --       ,'CASH (AGENCY TO AGENCY) PROVIDER' AS Type
  --       ,dbo.PaymentCashAgentToAgent.[Date]
  --       ,Agencies_1.Code + ' TO ' + dbo.Agencies.Code + ' - ' + dbo.Providers.Name +
  --        CASE
  --          WHEN dbo.ProviderTypes.Code = 'C02' THEN ' - ' + ISNULL((SELECT TOP 1
  --                mt.Number
  --              FROM MoneyTransferxAgencyNumbers mt
  --              WHERE mt.AgencyId = dbo.PaymentCashAgentToAgent.AgencyId
  --              AND mt.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId)
  --            , 'NOT REGISTERED')
  --          ELSE ''
  --        END AS Description
  --       ,dbo.PaymentCashAgentToAgent.Usd AS Usd
  --       ,CAST(1 as BIT)
  --       ,NULL
  --      FROM dbo.PaymentCashAgentToAgent
  --      INNER JOIN dbo.Agencies AS Agencies_1
  --        ON dbo.PaymentCashAgentToAgent.AgencyId = Agencies_1.AgencyId
  --      INNER JOIN dbo.Agencies
  --        ON dbo.PaymentCashAgentToAgent.FromAgencyId = dbo.Agencies.AgencyId
  --      INNER JOIN dbo.Providers
  --        ON dbo.Providers.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId
  --      INNER JOIN dbo.ProviderTypes
  --        ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
  --      WHERE CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
  --      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
  --      AND dbo.PaymentCashAgentToAgent.AgencyId = @AgencyId;
  --
  --  END;

  -- Bill taxes
  IF (@Type IS NULL
    OR @Type = 5)
  BEGIN
    INSERT INTO @Result
      SELECT
        4
       ,'BILL TAXES' AS Type
       ,dbo.PropertiesBillTaxes.CreationDate
       ,dbo.Properties.Name + ' (' + dbo.Properties.PIN + ') ' + CONVERT(VARCHAR, FromDate, 110) + ' TO ' + CONVERT(VARCHAR, ToDate, 110) AS Description
       ,dbo.PropertiesBillTaxes.Usd AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - dbo.PropertiesBillTaxes.Usd
      FROM dbo.PropertiesBillTaxes
      INNER JOIN dbo.Properties
        ON dbo.PropertiesBillTaxes.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId
      WHERE AgencyId = @AgencyId
      AND pc.Code = 'CODE01'
      AND CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE) <= CAST(@ToDate AS DATE);

  END;

  -- Bill water
  IF (@Type IS NULL
    OR @Type = 6)
  BEGIN
    INSERT INTO @Result
      SELECT
        5
       ,'BILL WATER' AS Type
       ,dbo.PropertiesBillWater.CreationDate
       ,dbo.Properties.Name + ' (' + dbo.Properties.BillNumber + ')' + '  ' + CONVERT(VARCHAR, FromDate, 110) + ' TO ' + CONVERT(VARCHAR, ToDate, 110) AS Description
       ,dbo.PropertiesBillWater.Usd AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - dbo.PropertiesBillWater.Usd
      FROM dbo.PropertiesBillWater
      INNER JOIN dbo.Properties
        ON dbo.PropertiesBillWater.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId
      WHERE AgencyId = @AgencyId
      AND pc.Code = 'CODE01'
      AND CAST(dbo.PropertiesBillWater.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.PropertiesBillWater.CreationDate AS DATE) <= CAST(@ToDate AS DATE);

  END;




  -- Bill insurance
  IF (@Type IS NULL
    OR @Type = 7)
  BEGIN
    INSERT INTO @Result
      SELECT
        6
       ,'BILL INSURANCE' AS Type
       ,pb.CreationDate
       ,dbo.Properties.Name + ' (' + RIGHT(pb.PolicyNumberSaved, 4) + ') ' + CONVERT(VARCHAR, pb.FromDate, 110) + ' TO ' + CONVERT(VARCHAR, pb.ToDate, 110) AS Description
       ,pb.Usd AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - pb.Usd
      FROM dbo.PropertiesBillInsurance pb
      INNER JOIN dbo.Properties
        ON pb.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = pb.ProviderCommissionPaymentTypeId
      WHERE pb.AgencyId = @AgencyId
      AND pc.Code = 'CODE01'
      AND CAST(pb.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(pb.CreationDate AS DATE) <= CAST(@ToDate AS DATE);

  END;

  -- Bill labor
  IF (@Type IS NULL
    OR @Type = 8)
  BEGIN
    INSERT INTO @Result
      SELECT
        7
       ,'BILL LABOR' AS Type
       ,pb.CreationDate
       ,dbo.Properties.Name + ' ' +

        CASE
          WHEN pb.ApartmentId IS NULL THEN ''
          ELSE '#' + a.Number + ' '
        END +

        '- ' + pb.Name AS Description
       ,pb.Usd AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - pb.Usd
      FROM dbo.PropertiesBillLabor pb
      INNER JOIN dbo.Properties
        ON pb.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = pb.ProviderCommissionPaymentTypeId
      LEFT JOIN Apartments a
        ON pb.ApartmentId = a.ApartmentsId
      WHERE AgencyId = @AgencyId
      AND pc.Code = 'CODE01'
      AND CAST(pb.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(pb.CreationDate AS DATE) <= CAST(@ToDate AS DATE);

  END;

  -- Bill labor
  IF (@Type IS NULL
    OR @Type = 8)
  BEGIN
    INSERT INTO @Result
      SELECT
        7
       ,'BILL LABOR' AS Type
       ,pb.CreationDate
       ,dbo.Properties.Name + ' ' +

        CASE
          WHEN pb.ApartmentId IS NULL THEN ''
          ELSE '#' + a.Number + ' '
        END +

        '- ' + pb.Name + ' ' + pb.MoneyOrderNumber AS Description
       ,pb.Usd AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - pb.Usd
      FROM dbo.PropertiesBillLabor pb
      INNER JOIN dbo.Properties
        ON pb.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = pb.ProviderCommissionPaymentTypeId
      LEFT JOIN Apartments a
        ON pb.ApartmentId = a.ApartmentsId
      WHERE AgencyId = @AgencyId
      AND pc.Code = 'CODE06'
      AND CAST(pb.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(pb.CreationDate AS DATE) <= CAST(@ToDate AS DATE);

  END;


  -- Bill others
  IF (@Type IS NULL
    OR @Type = 9)
  BEGIN
    INSERT INTO @Result
      SELECT
        8
       ,'BILL OTHERS CREDIT' AS Type
       ,dbo.PropertiesBillOthers.[Date]
       ,dbo.Properties.Name + ' (' + dbo.PropertiesBillOthers.Description + ') ' AS Description
       ,dbo.PropertiesBillOthers.Usd AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - dbo.PropertiesBillOthers.Usd
      FROM dbo.PropertiesBillOthers
      INNER JOIN dbo.Properties
        ON dbo.PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId
      WHERE AgencyId = @AgencyId
      AND pc.Code = 'CODE01'
      AND IsCredit = 1
      AND CAST(dbo.PropertiesBillOthers.[Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.PropertiesBillOthers.[Date] AS DATE) <= CAST(@ToDate AS DATE)

      UNION ALL

      SELECT
        8
       ,'BILL OTHERS DEBIT' AS Type
       ,dbo.PropertiesBillOthers.[Date]
       ,dbo.Properties.Name + ' (' + dbo.PropertiesBillOthers.Description + ') ' AS Description
       ,0 Credit
       ,dbo.PropertiesBillOthers.Usd AS Debit
       ,NULL
       ,0 + dbo.PropertiesBillOthers.Usd
      FROM dbo.PropertiesBillOthers
      INNER JOIN dbo.Properties
        ON dbo.PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId
      WHERE AgencyId = @AgencyId
      AND pc.Code = 'CODE01'
      AND IsCredit = 0
      AND CAST(dbo.PropertiesBillOthers.[Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.PropertiesBillOthers.[Date] AS DATE) <= CAST(@ToDate AS DATE);
  END;


  ---- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --admin modulo admin to cashier  (cashadmin 0, iscashier 0 )
  --cashier modulo cashier to cashier (cashadmin 0, iscashier 1)
  --cashier daily cashier to cashier (cashadmin 0, iscashier 1)
  --cashier daily cashier to admin (cashadmin 1, iscashier 0)
  -- Closing extra fund -- esta
  IF (@Type IS NULL
    OR @Type = 10)
  BEGIN


    INSERT INTO @Result --admin a cajero y cashier to cashier
      SELECT
        9
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,0 AS Credit
       ,SUM(t.Usd) Debit
       ,NULL
       ,0 + SUM(t.Usd)
      FROM (SELECT
          'EXTRA FUND' AS Type
         ,CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate
         ,'CLOSING EXTRA FUND TO ' + dbo.Users.Name AS Description
         ,dbo.ExtraFund.Usd AS Usd
        FROM dbo.ExtraFund
        INNER JOIN dbo.Users
          ON dbo.ExtraFund.AssignedTo = dbo.Users.UserId
        INNER JOIN dbo.UserTypes
          ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
        WHERE (IsCashier = 1)
        AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        AND AgencyId = @AgencyId) t
      GROUP BY t.Type
              ,CAST(t.CreationDate AS DATE)
              ,t.Description
      UNION ALL
      SELECT
        9
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Usd) AS Credit
       ,0 Debit
       ,NULL
       ,0 - SUM(t.Usd)
      FROM (SELECT
          'EXTRA FUND' AS Type
         ,CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate
         ,'CLOSING EXTRA FUND FROM ' + dbo.Users.Name AS Description
         ,dbo.ExtraFund.Usd AS Usd
        FROM dbo.ExtraFund
        INNER JOIN dbo.Users
          ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
        INNER JOIN dbo.UserTypes
          ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
        WHERE (IsCashier = 1)
        AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        AND AgencyId = @AgencyId) t
      GROUP BY t.Type
              ,CAST(t.CreationDate AS DATE)
              ,t.Description
      UNION ALL
      SELECT
        10
       ,'CASH FOR ADMIN' AS Type
       ,CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate
       ,'DAILY ' + dbo.Users.Name + ' -REASON: ' + dbo.ExtraFund.Reason AS Description
       ,0 AS Credit
       ,SUM(dbo.ExtraFund.Usd) AS Debit
       ,NULL
       ,0 + SUM(dbo.ExtraFund.Usd)
      FROM dbo.ExtraFund
      INNER JOIN dbo.Users
        ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
      INNER JOIN dbo.UserTypes
        ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
      WHERE CashAdmin = 1
      AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND AgencyId = @AgencyId
      GROUP BY CAST(dbo.ExtraFund.CreationDate AS DATE)
              ,dbo.Users.Name
              ,dbo.ExtraFund.Reason

      UNION ALL --admin a cajero
      SELECT
        10.1
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Usd) AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - SUM(t.Usd) AS Usd
      FROM (SELECT
          'ADMIN TO CASHIER' AS Type
         ,CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate
         ,'CLOSING EXTRA FUND TO ' + ur.Name AS Description
         ,dbo.ExtraFund.Usd AS Usd
        FROM dbo.ExtraFund
        INNER JOIN dbo.Users
          ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
        INNER JOIN dbo.Users ur
          ON dbo.ExtraFund.AssignedTo = ur.UserId
        INNER JOIN dbo.UserTypes
          ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType
        WHERE ((IsCashier = 0
        AND CashAdmin = 0)
        )
        AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        AND AgencyId = @AgencyId) t
      GROUP BY t.Type
              ,CAST(t.CreationDate AS DATE)
              ,t.Description
  END;

  -- Cash fund -- esta
  IF (@Type IS NULL
    OR @Type = 11)
  BEGIN
    INSERT INTO @Result
      SELECT
        11
       ,'CASH FUND' AS Type
       ,dbo.CashFundModifications.CreationDate
       ,'CASH FUND - ' + dbo.Users.Name AS Description
       ,SUM(dbo.CashFundModifications.CreditCashFund) AS Credit
       ,0 AS Debit
       ,NULL
       ,-SUM(dbo.CashFundModifications.CreditCashFund) AS Balance

      FROM dbo.CashFundModifications
      INNER JOIN dbo.Cashiers
        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
      INNER JOIN dbo.Users
        ON dbo.Cashiers.UserId = dbo.Users.UserId
      WHERE AgencyId = @AgencyId
      AND dbo.CashFundModifications.CreditCashFund > 0
      AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      GROUP BY dbo.CashFundModifications.CreationDate
              ,dbo.Users.Name;

    INSERT INTO @Result
      SELECT
        11
       ,'CASH FUND REFUNDED' AS Type
       ,dbo.CashFundModifications.CreationDate
       ,'CASH FUND - ' + dbo.Users.Name AS Description
       ,0 AS Credit
       ,SUM(dbo.CashFundModifications.DebitCashFund) AS Debit
       ,NULL
       ,SUM(dbo.CashFundModifications.DebitCashFund) AS Balance

      FROM dbo.CashFundModifications
      INNER JOIN dbo.Cashiers
        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
      INNER JOIN dbo.Users
        ON dbo.Cashiers.UserId = dbo.Users.UserId
      WHERE AgencyId = @AgencyId
      AND dbo.CashFundModifications.DebitCashFund > 0
      AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      GROUP BY dbo.CashFundModifications.CreationDate
              ,dbo.Users.Name;

  END;

  -- Money Distribution 
  IF (@Type IS NULL
    OR @Type = 13)
  BEGIN
    INSERT INTO @Result
      SELECT
        12
       ,'MONEY DISTRIBUTION' AS Type
       ,CAST(d.CreationDate AS DATE) AS CreationDate
       ,'CLOSING DAILY' AS Description
       ,SUM(dd.Usd) AS Credit
       ,0 AS Debit
       ,NULL
       ,0 - SUM(dd.Usd)
      FROM DailyDistribution dd
      INNER JOIN Daily d
        ON d.DailyId = dd.DailyId
      WHERE dd.Usd > 0 AND (CAST(d.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(d.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND d.AgencyId = @AgencyId
      GROUP BY CAST(d.CreationDate AS DATE)
      ORDER BY CreationDate,
      Type;



  END;

  IF (@Type IS NULL
    OR @Type = 12)
  BEGIN
    INSERT INTO @Result
      SELECT
        13
       ,'PAYMENT BANK' AS Type
       ,dbo.PaymentBanks.Date
       ,'BANK DEPOSIT ' + '****' + BankAccounts.AccountNumber + ' - ' + a.Code + ' - ' + a.Name AS Description
       ,dbo.PaymentBanks.USD AS Credit
       ,0 AS Debit
       ,'****' + BankAccounts.AccountNumber + ' ' + Bank.Name AccountNumberBank
       ,0 - dbo.PaymentBanks.USD
      FROM dbo.PaymentBanks
      INNER JOIN BankAccounts
        ON dbo.PaymentBanks.BankAccountId = BankAccounts.BankAccountId
      INNER JOIN Bank
        ON Bank.BankId = BankAccounts.BankId
      LEFT JOIN dbo.Agencies a
        ON a.AgencyId = dbo.PaymentBanks.AgencyId
      WHERE CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.PaymentBanks.AgencyId = @AgencyId;
  END;

  ---- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  IF (@Type IS NULL
    OR @Type = 14)
  BEGIN
    INSERT INTO @Result
      SELECT
        14
       ,'COMMISSION' AS Type

       ,c.CreationDate Date
       ,dbo.Providers.Name + ' ' +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ' - ' + CAST(ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = c.AgencyId
              AND mt.ProviderId = c.ProviderId)
            , 'NUMBER NOT REGISTERED') AS VARCHAR) + ' ' + '(' + m.Description +
            ' ' + CAST(c.year AS VARCHAR) + ')'
          ELSE '' + '(' + m.Description + ' ' + CAST(c.year AS VARCHAR) + ')'
        END AS Description
       ,0 AS Credit
       ,c.USD AS Debit
       ,NULL
       ,0 + c.USD
      FROM dbo.ProviderCommissionPayments c
      INNER JOIN dbo.Providers
        ON c.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      INNER JOIN ProviderCommissionPaymentTypes pt
        ON pt.ProviderCommissionPaymentTypeId = c.ProviderCommissionPaymentTypeId
      LEFT JOIN Months m
        ON m.MonthId = c.[month]
      WHERE (dbo.ProviderTypes.Code != 'C14')
      AND pt.Code = 'CODE01'
      AND CAST(c.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(c.CreationDate AS Date) <= CAST(@ToDate AS Date)
      AND c.AgencyId = @AgencyId

      UNION ALL-----------------------------------------------------------------


      SELECT -- esta
        14
       ,'COMMISSION' AS Type
        --       ,dbo.[fn_GetNextDayPeriod](Year, Month) Date
       ,C.CreationDate Date
       ,dbo.Providers.Name +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ' - ' + CAST(ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = C.AgencyId
              AND mt.ProviderId = C.ProviderId)
            , 'NUMBER NOT REGISTERED') AS VARCHAR)
          ELSE ''
        END + ' (' + m.Description + ' ' + CAST(C.year AS VARCHAR) + ')'
        AS Description
       ,0 AS Credit
       ,co.Usd AS Debit
       ,NULL
       ,0 + co.Usd
      FROM dbo.OtherCommissions co
      INNER JOIN ProviderCommissionPayments C
        ON C.ProviderCommissionPaymentId = co.ProviderCommissionPaymentId
      INNER JOIN dbo.Providers
        ON C.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      INNER JOIN ProviderCommissionPaymentTypes pt
        ON pt.ProviderCommissionPaymentTypeId = co.ProviderCommissionPaymentTypeId
          AND pt.Code = 'CODE01'--Cash
      LEFT JOIN Months m
        ON m.MonthId = C.[month]
      WHERE

      --      (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS Date)
      --      OR @FromDate IS NULL)
      --      AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS Date)
      --      OR @ToDate IS NULL)
      CAST(C.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(C.CreationDate AS Date) <= CAST(@ToDate AS Date)
      AND C.AgencyId = @AgencyId;
  END;

  -- !!!!!!!!!!!!!!!!!!!!
  IF (@Type IS NULL
    OR @Type = 15)
  BEGIN
    INSERT INTO @Result
      SELECT
        15
       ,'CLOSING PAYROLL' AS Type
       ,CAST(p.PaidOn AS DATE) PaidOn
       ,'PAYROLL' + ' ' + FORMAT(p.FromDate, 'MM-dd-yyyy', 'en-US') + ' TO ' + FORMAT(p.ToDate, 'MM-dd-yyyy', 'en-US') AS Description
       ,SUM(p.Cash) AS Credit --task 5806
       ,0 AS Debit
       ,NULL
       ,0 - SUM(p.Cash)--tasl 5806 

      FROM dbo.Payrolls p
      WHERE CAST(p.PaidOn AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(p.PaidOn AS DATE) <= CAST(@ToDate AS DATE)
      AND p.AgencyId = @AgencyId
      GROUP BY CAST(p.PaidOn AS DATE)
              ,(p.FromDate)
              ,(p.ToDate)
  END;

  -- Other agent to agent (From agency)
  IF (@Type IS NULL
    OR @Type = 4)
  BEGIN
    INSERT INTO @Result
      SELECT
        16
       ,'CASH (AGENCY TO AGENCY)' AS Type
       ,dbo.PaymentOthersAgentToAgent.[Date]
       ,dbo.Agencies.Code + ' TO ' + Agencies_1.Code + ' - ' + Agencies_1.Name + ' (' + CAST(dbo.PaymentOthersAgentToAgent.Note AS VARCHAR(50)) + ')' AS Description
       ,dbo.PaymentOthersAgentToAgent.Usd Credit
       ,0 AS Debit
       ,NULL
       ,0 - dbo.PaymentOthersAgentToAgent.Usd
      FROM dbo.PaymentOthersAgentToAgent
      INNER JOIN dbo.Agencies
        ON dbo.PaymentOthersAgentToAgent.FromAgency = dbo.Agencies.AgencyId
      INNER JOIN dbo.Agencies AS Agencies_1
        ON dbo.PaymentOthersAgentToAgent.ToAgency = Agencies_1.AgencyId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = dbo.PaymentOthersAgentToAgent.ProviderCommissionPaymentTypeId
      WHERE dbo.PaymentOthersAgentToAgent.FromAgency = @AgencyId
      AND pc.Code = 'CODE01'
      AND CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.PaymentOthersAgentToAgent.DeletedOn IS NULL
    ;

  END;

  -- Other agent to agent (To agency)
  IF (@Type IS NULL
    OR @Type = 4)
  BEGIN
    INSERT INTO @Result
      SELECT
        17
       ,'CASH (AGENCY TO AGENCY)' AS Type
       ,dbo.PaymentOthersAgentToAgent.[Date]
       ,Agencies.Code + ' TO ' + Agencies_1.Code + ' (' + CAST(dbo.PaymentOthersAgentToAgent.Note AS VARCHAR(50)) + ')' AS Description
       ,0 AS Credit
       ,dbo.PaymentOthersAgentToAgent.Usd AS Debit
       ,NULL
       ,0 + dbo.PaymentOthersAgentToAgent.Usd
      FROM dbo.PaymentOthersAgentToAgent
      INNER JOIN dbo.Agencies
        ON dbo.PaymentOthersAgentToAgent.FromAgency = dbo.Agencies.AgencyId
      INNER JOIN dbo.Agencies AS Agencies_1
        ON dbo.PaymentOthersAgentToAgent.ToAgency = Agencies_1.AgencyId
      INNER JOIN dbo.ProviderCommissionPaymentTypes pc
        ON pc.ProviderCommissionPaymentTypeId = dbo.PaymentOthersAgentToAgent.ProviderCommissionPaymentTypeId
      WHERE dbo.PaymentOthersAgentToAgent.ToAgency = @AgencyId
      AND pc.Code = 'CODE01'
      AND CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.PaymentOthersAgentToAgent.DeletedOn IS NULL
    ;

  END;

  -- CASH (AGENCY TO AGENCY) PROVIDER
  IF (@Type IS NULL
    OR @Type = 16)
  BEGIN

    -- FROM (Sent)
    INSERT INTO @Result
      SELECT
        18
       ,'CASH (AGENCY TO AGENCY) DAILY' AS Type
       ,e.CreationDate
       ,'FROM ' + a.Code + ' TO ' + at.Code + ' ASSIGNED TO ' + u.Name
       ,(e.Usd * -1) AS Credit
       ,0 AS Debit
       ,NULL
       ,(e.Usd)
      FROM dbo.ExtraFundAgencyToAgency e
      INNER JOIN dbo.Agencies a
        ON e.FromAgencyId = a.AgencyId
      INNER JOIN dbo.Agencies at
        ON e.ToAgencyId = at.AgencyId
      INNER JOIN dbo.Users u
        ON u.UserId = e.AssignedTo
      WHERE e.FromAgencyId = @AgencyId
      AND CAST(e.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(e.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      UNION ALL
      SELECT
        18
       ,'CASH (AGENCY TO AGENCY) DAILY' AS Type
       ,e.CreationDate
       ,'TO ' + at.Code + ' FROM ' + a.Code + +' ASSIGNED TO ' + u.Name
       ,0 AS Credit
       ,(e.Usd * -1) AS Debit
       ,NULL
       ,(e.Usd * -1)
      FROM dbo.ExtraFundAgencyToAgency e
      INNER JOIN dbo.Agencies a
        ON e.FromAgencyId = a.AgencyId
      INNER JOIN dbo.Agencies at
        ON e.ToAgencyId = at.AgencyId
      INNER JOIN dbo.Users u
        ON u.UserId = e.AssignedTo
      WHERE e.FromAgencyId = @AgencyId
      AND CAST(e.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(e.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND e.AcceptedBy IS NOT NULL

    -- TO (Received)
    INSERT INTO @Result
      SELECT
        18
       ,'CASH (AGENCY TO AGENCY) DAILY' AS Type
       ,e.AcceptedDate
       ,'TO ' + at.Code + ' FROM ' + a.Code + ' ASSIGNED TO ' + u.Name
       ,0 AS Credit
       ,(e.Usd * -1) AS Debit
       ,NULL
       ,(e.Usd * -1)
      FROM dbo.ExtraFundAgencyToAgency e
      INNER JOIN dbo.Agencies a
        ON e.FromAgencyId = a.AgencyId
      INNER JOIN dbo.Agencies AS at
        ON e.ToAgencyId = at.AgencyId
      INNER JOIN dbo.Users u
        ON u.UserId = e.AssignedTo
      WHERE e.ToAgencyId = @AgencyId
      AND e.AcceptedBy IS NOT NULL
      AND CAST(e.AcceptedDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(e.AcceptedDate AS DATE) <= CAST(@ToDate AS DATE)
      UNION ALL
      SELECT
        18
       ,'CASH (AGENCY TO AGENCY) DAILY' AS Type
       ,e.AcceptedDate
       ,'FROM ' + a.Code + ' TO ' + at.Code + ' ASSIGNED TO ' + u.Name
       ,(e.Usd * -1) AS Credit
       ,0 AS Debit
       ,NULL
       ,(e.Usd)
      FROM dbo.ExtraFundAgencyToAgency e
      INNER JOIN dbo.Agencies a
        ON e.FromAgencyId = a.AgencyId
      INNER JOIN dbo.Agencies AS at
        ON e.ToAgencyId = at.AgencyId
      INNER JOIN dbo.Users u
        ON u.UserId = e.AssignedTo
      WHERE e.ToAgencyId = @AgencyId
      AND e.AcceptedBy IS NOT NULL
      AND CAST(e.AcceptedDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(e.AcceptedDate AS DATE) <= CAST(@ToDate AS DATE)
      AND e.AcceptedBy IS NOT NULL

  END
  IF (@Type IS NULL
    OR @Type = 17)
  BEGIN

    INSERT INTO @Result --Insurance new policy adjustment
      SELECT
        19
       ,'INSURANCE' Type
       ,CAST(c.ValidatedOn AS DATE) AS DATE
       ,a.Code + ' - NEW POLICY #' + c.PolicyNumber AS Description
       ,SUM(ISNULL(c.ValidatedUSD, 0)) Credit
       ,0 Debit
       ,NULL
       ,SUM(ISNULL(c.ValidatedUSD, 0)) * -1 BalanceDetail
      FROM dbo.InsurancePolicy c
      INNER JOIN dbo.InsurancePaymentType t
        ON t.InsurancePaymentTypeId = c.InsurancePaymentTypeId
      INNER JOIN Agencies a
        ON c.CreatedInAgencyId = a.AgencyId
      WHERE (CAST(c.ValidatedOn AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(c.ValidatedOn AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND c.USD > 0
      AND c.ValidatedBy IS NOT NULL
      AND t.Code = 'C01'
      AND c.ValidatedAgencyId = @AgencyId
      GROUP BY c.PolicyNumber
              ,CAST(c.ValidatedOn AS DATE)
              ,a.Code

    INSERT INTO @Result --Insurance monthly payment
      SELECT
        20
       ,'INSURANCE' Type
       ,CAST(c.ValidatedOn AS DATE) AS DATE
       ,a.Code + ' - MONTHLY PAYMENT #' + p.PolicyNumber AS Description
       ,SUM(ISNULL(c.ValidatedUSD, 0)) Credit
       ,0 Debit
       ,NULL
       ,SUM(ISNULL(c.ValidatedUSD, 0)) * -1 BalanceDetail
      FROM dbo.InsuranceMonthlyPayment c
      INNER JOIN dbo.InsurancePolicy p
        ON p.InsurancePolicyId = c.InsurancePolicyId
      INNER JOIN dbo.InsurancePaymentType t
        ON t.InsurancePaymentTypeId = c.InsurancePaymentTypeId
      INNER JOIN Agencies a
        ON c.CreatedInAgencyId = a.AgencyId
      WHERE (CAST(c.ValidatedOn AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(c.ValidatedOn AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND c.USD > 0
      AND c.ValidatedBy IS NOT NULL
      AND t.Code = 'C01'
      AND c.ValidatedAgencyId = @AgencyId
      GROUP BY p.PolicyNumber
              ,CAST(c.ValidatedOn AS DATE)
              ,a.Code

    INSERT INTO @Result --Insurance monthly payment
      SELECT
        21
       ,'INSURANCE' Type
       ,CAST(c.ValidatedOn AS DATE) AS DATE
       ,a.Code + ' - REGISTRATION RELEASE (S.O.S) CLIENT: ' + c.ClientName AS Description
       ,SUM(ISNULL(c.ValidatedUSD, 0)) Credit
       ,0 Debit
       ,NULL
       ,SUM(ISNULL(c.ValidatedUSD, 0)) * -1 BalanceDetail
      FROM dbo.InsuranceRegistration c
      INNER JOIN dbo.InsurancePaymentType t
        ON t.InsurancePaymentTypeId = c.InsurancePaymentTypeId
      INNER JOIN Agencies a
        ON c.CreatedInAgencyId = a.AgencyId
      WHERE (CAST(c.ValidatedOn AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(c.ValidatedOn AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND c.USD > 0
      AND c.ValidatedBy IS NOT NULL
      AND t.Code = 'C01'
      AND c.ValidatedAgencyId = @AgencyId
      GROUP BY c.ClientName
              ,CAST(c.ValidatedOn AS DATE)
              ,a.Code

  END

  IF (@Type IS NULL
    OR @Type = 18)
  BEGIN

    INSERT INTO @Result --Ticket MONEY ORDER
      SELECT
        22
       ,'TRAFFIC TICKET' Type
       ,CAST(c.UpdateToPendingDate AS DATE) AS DATE
       ,a.Code + ' - TRAFFIC TICKET - ' + c.TicketNumber AS Description
       ,ISNULL(c.USD, 0) Credit
       ,0 Debit
       ,NULL
       ,ISNULL(c.USD, 0) * -1 BalanceDetail
      FROM dbo.Tickets c
      INNER JOIN dbo.Agencies a
        ON a.AgencyId = c.AgencyId
      INNER JOIN dbo.TicketPaymentTypes p
        ON p.TicketPaymentTypeId = c.TicketPaymentTypeId
      WHERE (CAST(c.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (CAST(c.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND c.Usd > 0
      AND c.UpdateToPendingDate IS NOT NULL
      AND c.ChangedToPendingByAgency = @AgencyId
      AND p.Code = 'C01'
      AND UpdatedToPendingByAdmin = 1

  END


  RETURN;
END;


GO