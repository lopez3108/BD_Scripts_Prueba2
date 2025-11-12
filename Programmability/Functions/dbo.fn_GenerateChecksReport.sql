SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de checks

--LASTUPDATEDBY: SERGIO
--LASTUPDATEDON:24-04-2024
--CAMBIOS EN 5799, Add column Transactions

-- =============================================
-- Author:      sa
-- Create date: 11/07/2024 2:57 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================
-- =============================================
-- Author:      sa
-- Create date: 26/07/2024 1:25 p. m.
-- Database:    [copySecure26-07-2024]
-- Description: AND pc.ProviderCommissionPaymentId NOT IN(SELECT top 1 o.ProviderCommissionPaymentId FROM
--                OtherCommissions o WHERE o.ProviderCommissionPaymentId = pc.ProviderCommissionPaymentId )
-- =============================================




CREATE       FUNCTION [dbo].[fn_GenerateChecksReport] (@AgencyId INT,
@FromDate DATETIME = NULL, @ToDate DATETIME = NULL,
@Type INT = NULL)

RETURNS @result TABLE (
  [Index] INT
 ,[Type] VARCHAR(30)
 ,CreationDate DATETIME NULL
 ,[Description] VARCHAR(100) NULL
 ,[Transactions] INT
 ,Usd DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS
BEGIN


  IF (@Type IS NULL
    OR @Type = 1)
  BEGIN
    INSERT INTO @result
      SELECT
        2
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,SUM(t.Usd) AS Balance
      FROM (SELECT
          'CLOSING CHECKS' AS Type
         ,CAST(dbo.ChecksEls.CreationDate AS DATE) AS CreationDate
         ,'CLOSING CHECKS' AS Description
         ,1 Transactions
         ,Amount AS Usd
        FROM dbo.ChecksEls
        WHERE ((@FromDate IS NULL)
        OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
        AND AgencyId = @AgencyId) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;

  -- Closing check returned
  IF (@Type IS NULL
    OR @Type = 2)
  BEGIN
    INSERT INTO @result
      SELECT
        3
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,SUM(t.Usd) AS Balance
      FROM (SELECT
          'CHECK RETURNED' AS Type
         ,CAST(rp.CreationDate AS DATE) AS CreationDate
         ,'CHECK PAYMENT (CHECK #' + rp.CheckNumber + ')' AS Description
         ,1 Transactions
         ,rp.Usd AS Usd
        FROM dbo.ReturnPayments rp
        INNER JOIN dbo.ReturnPaymentMode rpm
          ON rpm.ReturnPaymentModeId = rp.ReturnPaymentModeId
        WHERE rpm.Code = 'C01'
        AND ((@FromDate IS NULL)
        OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
        AND AgencyId = @AgencyId) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;

  -- Closing check commision
  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN
    INSERT INTO @result
      SELECT
        4
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,SUM(t.Usd) AS Balance
      FROM (SELECT
          'CHECK COMMISSION' AS Type


         ,CAST(pc.CreationDate AS DATE) AS CreationDate
         ,REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '') + ' (CHECK #' + pc.CheckNumber + ')' + ' ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) AS Description
         ,1 Transactions
         ,pc.Usd AS Usd
        FROM dbo.ProviderCommissionPayments pc
        INNER JOIN dbo.ProviderCommissionPaymentTypes rpm
          ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId
        INNER JOIN Providers
          ON Providers.ProviderId = pc.ProviderId
        WHERE rpm.Code = 'CODE02'
        AND pc.IsForex = CAST(0 AS BIT)
        AND ((@FromDate IS NULL)
        OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))

        AND AgencyId = @AgencyId AND pc.ProviderCommissionPaymentId NOT IN(SELECT top 1 o.ProviderCommissionPaymentId FROM
                OtherCommissions o WHERE o.ProviderCommissionPaymentId = pc.ProviderCommissionPaymentId )
--        AND pc.Usd > 0
        ) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;


  --Other commissions

  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN



    INSERT INTO @result
      SELECT
        5
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,SUM(t.Usd) AS Balance
      FROM (SELECT
          'CHECK COMMISSION' AS Type
         ,CAST(pc.CreationDate AS DATE) AS CreationDate
         ,REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '') + ' (CHECK #' + O.CheckNumber + ')' + ' ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) AS Description
         ,1 Transactions
         ,O.Usd AS Usd
        FROM [OtherCommissions] O
        INNER JOIN dbo.ProviderCommissionPayments pc
          ON O.ProviderCommissionPaymentId = pc.ProviderCommissionPaymentId
        INNER JOIN dbo.ProviderCommissionPaymentTypes rpm
          ON rpm.ProviderCommissionPaymentTypeId = O.ProviderCommissionPaymentTypeId
        INNER JOIN Providers
          ON Providers.ProviderId = pc.ProviderId

        WHERE rpm.Code = 'CODE02'
        AND ((@FromDate IS NULL)
        OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))

        AND AgencyId = @AgencyId) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;

  -- Closing check commision
  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN
    INSERT INTO @result
      SELECT
        4
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,SUM(t.Usd) AS Balance
      FROM (SELECT
          'M. ORDER COMMISSION' AS Type


         ,CAST(pc.CreationDate AS DATE) AS CreationDate
         ,REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '') + ' ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) AS Description
         ,1 Transactions
         ,pc.Usd AS Usd
        FROM dbo.ProviderCommissionPayments pc
        INNER JOIN dbo.ProviderCommissionPaymentTypes rpm
          ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId
        INNER JOIN Providers
          ON Providers.ProviderId = pc.ProviderId
        WHERE rpm.Code = 'CODE06'
        AND ((@FromDate IS NULL)
        OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))

        AND AgencyId = @AgencyId
        AND pc.Usd > 0) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;

  -- Process checks
  IF (@Type IS NULL
    OR @Type = 4)
  BEGIN
    INSERT INTO @result
      SELECT
        6
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,-SUM(t.Usd) AS Balance
      FROM (SELECT
          'PROCESS CHECKS' AS Type
         ,CAST(pc.Date AS DATE) AS CreationDate
         ,dbo.Agencies.Code + ' - ' + Agencies_1.Code + ' ' + '' +
          CASE
            WHEN dbo.ProviderTypes.Code = 'C02' THEN ISNULL((SELECT TOP 1
                  mt.Number
                FROM MoneyTransferxAgencyNumbers mt
                WHERE mt.AgencyId = pc.ToAgency
                AND mt.ProviderId = pc.ProviderId)
              , 'Not registered')
            ELSE dbo.Providers.Name
          END + ' ' + CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10)) + ' TO ' + CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) + ' BATCH: #' + pc.providerBatch AS Description
         ,pc.NumberChecks AS Transactions
         ,Usd AS Usd
        FROM dbo.PaymentChecksAgentToAgent pc
        INNER JOIN dbo.Agencies
          ON pc.FromAgency = dbo.Agencies.AgencyId
        INNER JOIN dbo.Agencies AS Agencies_1
          ON pc.ToAgency = Agencies_1.AgencyId
        INNER JOIN dbo.Providers
          ON pc.ProviderId = dbo.Providers.ProviderId
        INNER JOIN dbo.ProviderTypes
          ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
        WHERE ((@FromDate IS NULL)
        OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
        AND FromAgency = @AgencyId) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;

  -- Proccess checks fee
  --   IF(@Type IS NULL
  --          OR @Type = 5)

  --BEGIN

  --       INSERT INTO #Temp
  --              SELECT 
  --                     'PROCESSED CHECKS FEE' AS Type,
  --                     dbo.PaymentChecksAgentToAgent.Date AS CreationDate,
  --                     'FROM '+
  --              (
  --                  SELECT TOP 1 Code+' - '+Name
  --                  FROM dbo.Agencies
  --                  WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.FromAgency
  --              )+' TO '+
  --              (
  --                  SELECT TOP 1 Code+' - '+Name
  --                  FROM dbo.Agencies
  --                  WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency
  --              ) AS Description,
  --                     Fee AS Usd
  --              FROM dbo.PaymentChecksAgentToAgent
  --              WHERE FromAgency = @AgencyId 
  --                    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
  --                    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE)
  --			  AND Fee > 0


  --			  END

  -- Payment checks
  IF (@Type IS NULL
    OR @Type = 6)
  BEGIN
    INSERT INTO @result
      SELECT
        7
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,-SUM(t.Usd) AS Balance
      FROM (SELECT
          'PAYMENT CHECKS' AS Type
         ,CAST(pc.Date AS DATE) AS CreationDate
         ,dbo.Agencies.Code + '' + ' ' +
          CASE
            WHEN dbo.ProviderTypes.Code = 'C02' THEN ISNULL((SELECT TOP 1
                  mt.Number
                FROM MoneyTransferxAgencyNumbers mt
                WHERE mt.AgencyId = pc.AgencyId
                AND mt.ProviderId = pc.ProviderId)
              , 'Not registered')
            ELSE dbo.Providers.Name
          END + ' ' + CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10)) + ' TO ' + CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description
         ,1 Transactions
         ,Usd AS Usd
        FROM dbo.PaymentChecks pc
        INNER JOIN dbo.Agencies
          ON pc.AgencyId = dbo.Agencies.AgencyId
        INNER JOIN dbo.Providers
          ON pc.ProviderId = dbo.Providers.ProviderId
        INNER JOIN dbo.ProviderTypes
          ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
        WHERE ((@FromDate IS NULL)
        OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
        AND pc.AgencyId = @AgencyId) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;


  -- Closing check commision
  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN
    INSERT INTO @result
      SELECT
        8
       ,t.Type
       ,t.CreationDate
       ,t.Description
       ,SUM(t.Transactions) AS Transactions
       ,SUM(t.Usd) AS Usd
       ,SUM(t.Usd) AS Balance
      FROM (SELECT
          'CHECK COMMISSION' AS Type


         ,CAST(pc.CreationDate AS DATE) AS CreationDate
         ,REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '') + ' (CHECK #' + pc.CheckNumber + ')' + ' ' +
          dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) + ' ' + 'FOREX' AS Description
         ,1 Transactions
         ,pc.Usd AS Usd
        FROM dbo.ProviderCommissionPayments pc
        INNER JOIN dbo.ProviderCommissionPaymentTypes rpm
          ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId
        INNER JOIN Providers
          ON Providers.ProviderId = pc.ProviderId
        WHERE rpm.Code = 'CODE02'
        AND pc.IsForex = CAST(1 AS BIT)
        AND ((@FromDate IS NULL)
        OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
        AND ((@ToDate IS NULL)
        OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))

        AND AgencyId = @AgencyId
--        AND pc.Usd > 0
        ) t
      GROUP BY t.CreationDate
              ,t.Type
              ,t.Description;
  END;



  RETURN

END
GO