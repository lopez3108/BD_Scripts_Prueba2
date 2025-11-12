SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de checks

--LASTUPDATEDBY: SERGIO
--LASTUPDATEDON:24-04-2024
--CAMBIOS EN 5799, Add column Transactions

CREATE PROCEDURE [dbo].[sp_GetReportChecks] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@Type INT = NULL)
AS

BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = ISNULL((SELECT
      SUM(CAST(Balance AS DECIMAL(18, 2)))
    FROM [dbo].fn_GenerateChecksReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @Type))
  , 0)

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[Type] VARCHAR(30)
   ,CreationDate DATETIME NULL
   ,[Description] VARCHAR(100) NULL
   ,[Transactions] INT
   ,Usd DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)

  )


  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,'INITIAL BALANCE' Type
     ,CAST(@initialBalanceFinalDate AS DATE) CreationDate
     ,'INITIAL BALANCE' Description
     ,NULL
     ,NULL
     ,@BalanceDetail Balance


    UNION ALL

    SELECT
      *
    FROM [dbo].fn_GenerateChecksReport(@AgencyId, @FromDate, @ToDate, @Type)
    ORDER BY CreationDate,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Balance AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1

  ORDER BY CreationDate,
  [Index];
  DROP TABLE #Temp;



END




--     BEGIN
--         IF(@FromDate IS NULL)
--             BEGIN
--                 SET @FromDate = DATEADD(day, -10, @Date);
--                 SET @ToDate = @Date;
--         END;
--          DECLARE @initialBalanceFinalDate DATETIME
--  SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
--         CREATE TABLE #Temp
--         (RowIndex INT ,
--         [Type]        VARCHAR(30),
--          CreationDate  DATETIME NULL,
--          [Description] VARCHAR(100) NULL,
--          Usd           DECIMAL(18, 2)
--         );
--
---- Initial balance
--       
--                 INSERT INTO #Temp
--                        SELECT 
--                        1,
--                        'INITIAL BALANCE',
--                               CAST(@initialBalanceFinalDate AS DATE),
--                               'INITIAL BALANCE',
--                               dbo.fn_CalculateChecksInitialBalance(@AgencyId, @initialBalanceFinalDate);
-- 
--
---- Closing check
--         IF(@Type IS NULL
--            OR @Type = 1)
--             BEGIN
--                 INSERT INTO #Temp
--                        SELECT 
--                        2,
--                        t.Type,
--                               t.CreationDate,
--                               t.Description,
--                               SUM(t.Usd) AS Usd
--                        FROM
--                        (
--                            SELECT 'CLOSING CHECKS' AS Type,
--                                   CAST(dbo.ChecksEls.CreationDate AS DATE) AS CreationDate,
--                                   'CLOSING CHECKS' AS Description,
--                                   Amount AS Usd
--                            FROM dbo.ChecksEls
--                            WHERE((@FromDate IS NULL)
--                                  OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
--                                 AND ((@ToDate IS NULL)
--                                      OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
--                                 AND AgencyId = @AgencyId
--                        ) t
--                        GROUP BY t.CreationDate,
--                                 t.Type,
--                                 t.Description;
--         END;
--
---- Closing check returned
--         IF(@Type IS NULL
--            OR @Type = 2)
--             BEGIN
--                 INSERT INTO #Temp
--                        SELECT 3,
--                        t.Type,
--                               t.CreationDate,
--                               t.Description,
--                               SUM(t.Usd) AS Usd
--                        FROM
--                        (
--                            SELECT 'CHECK RETURNED' AS Type,
--                                   CAST(rp.CreationDate AS DATE) AS CreationDate,
--                                   'CHECK PAYMENT (CHECK #'+rp.CheckNumber+')' AS Description,
--                                   rp.Usd AS Usd
--                            FROM dbo.ReturnPayments rp
--                                 INNER JOIN dbo.ReturnPaymentMode rpm ON rpm.ReturnPaymentModeId = rp.ReturnPaymentModeId
--                            WHERE rpm.Code = 'C01'
--                                  AND ((@FromDate IS NULL)
--                                       OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
--                                  AND ((@ToDate IS NULL)
--                                       OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
--                                  AND AgencyId = @AgencyId
--                        ) t
--                        GROUP BY t.CreationDate,
--                                 t.Type,
--                                 t.Description;
--         END;
--
---- Closing check commision
--         IF(@Type IS NULL
--            OR @Type = 3)
--             BEGIN
--                 INSERT INTO #Temp
--                        SELECT 4,
--                        t.Type,
--                               t.CreationDate,
--                               t.Description,
--                               SUM(t.Usd) AS Usd
--                        FROM
--                        (
--                            SELECT 'CHECK COMMISSION' AS Type,
--                                   CAST(pc.CreationDate AS DATE) AS CreationDate,
--                                   REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '')+' (CHECK #'+pc.CheckNumber+')' AS Description,
--                                   pc.Usd AS Usd
--                            FROM dbo.ProviderCommissionPayments pc
--                                 INNER JOIN dbo.ProviderCommissionPaymentTypes rpm ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId
--                                 INNER JOIN Providers ON Providers.ProviderId = pc.ProviderId
--                            WHERE rpm.Code = 'CODE02'
--                                  AND ((@FromDate IS NULL)
--                                       OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
--                                  AND ((@ToDate IS NULL)
--                                       OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
--                                  AND AgencyId = @AgencyId
--								  AND pc.Usd > 0
--                        ) t
--                        GROUP BY t.CreationDate,
--                                 t.Type,
--                                 t.Description;
--         END;
--
--
--		 --Other commissions
--
--		 IF(@Type IS NULL
--            OR @Type = 3)
--             BEGIN
--                 INSERT INTO #Temp
--                        SELECT 5,
--                        t.Type,
--                               t.CreationDate,
--                               t.Description,
--                               SUM(t.Usd) AS Usd
--                        FROM
--                        (
--                            SELECT 'CHECK COMMISSION' AS Type,
--                                   CAST(pc.CreationDate AS DATE) AS CreationDate,
--                                   REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '')+' (CHECK #'+pc.CheckNumber+')' AS Description,
--                                   O.Usd AS Usd
--                            FROM dbo.ProviderCommissionPayments pc
--                                 INNER JOIN dbo.ProviderCommissionPaymentTypes rpm ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId
--                                 INNER JOIN Providers ON Providers.ProviderId = pc.ProviderId
--								 INNER JOIN [dbo].[OtherCommissions] O ON pc.ProviderCommissionPaymentId = O.ProviderCommissionPaymentId
--                            WHERE rpm.Code = 'CODE02'
--                                  AND ((@FromDate IS NULL)
--                                       OR (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
--                                  AND ((@ToDate IS NULL)
--                                       OR (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
--                                  AND AgencyId = @AgencyId
--                        ) t
--                        GROUP BY t.CreationDate,
--                                 t.Type,
--                                 t.Description;
--         END;
--
---- Process checks
--         IF(@Type IS NULL
--            OR @Type = 4)
--             BEGIN
--                 INSERT INTO #Temp
--                        SELECT 6
--                        ,t.Type,
--                               t.CreationDate,
--                               t.Description,
--                               SUM(t.Usd) AS Usd
--                        FROM
--                        (
--                            SELECT 'PROCESS CHECKS' AS Type,
--                                   CAST(pc.Date AS DATE) AS CreationDate,
--                                   dbo.Agencies.Code+' - '+Agencies_1.Code+' '+''+CASE
--                                                                                                                                   WHEN dbo.ProviderTypes.Code = 'C02'
--                                                                                                                                   THEN ISNULL(
--                                                                                                                                              (
--                                                                                                                                                  SELECT TOP 1 mt.Number
--                                                                                                                                                  FROM MoneyTransferxAgencyNumbers mt
--                                                                                                                                                  WHERE mt.AgencyId = pc.ToAgency
--                                                                                                                                                        AND mt.ProviderId = pc.ProviderId
--                                                                                                                                              ), 'Not registered')
--                                                                                                                                   ELSE dbo.Providers.Name
--                                                                                                                               END+' '+CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10))+' TO '+CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description,
--                                   Usd AS Usd
--                            FROM dbo.PaymentChecksAgentToAgent pc
--                                 INNER JOIN dbo.Agencies ON pc.FromAgency = dbo.Agencies.AgencyId
--                                 INNER JOIN dbo.Agencies AS Agencies_1 ON pc.ToAgency = Agencies_1.AgencyId
--                                 INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
--                                 INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--                            WHERE((@FromDate IS NULL)
--                                  OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
--                                 AND ((@ToDate IS NULL)
--                                      OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
--                                 AND FromAgency = @AgencyId
--                        ) t
--                        GROUP BY t.CreationDate,
--                                 t.Type,
--                                 t.Description;
--         END;
--
---- Proccess checks fee
--		--   IF(@Type IS NULL
--  --          OR @Type = 5)
--
--		--BEGIN
--
--  --       INSERT INTO #Temp
--  --              SELECT 
--  --                     'PROCESSED CHECKS FEE' AS Type,
--  --                     dbo.PaymentChecksAgentToAgent.Date AS CreationDate,
--  --                     'FROM '+
--  --              (
--  --                  SELECT TOP 1 Code+' - '+Name
--  --                  FROM dbo.Agencies
--  --                  WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.FromAgency
--  --              )+' TO '+
--  --              (
--  --                  SELECT TOP 1 Code+' - '+Name
--  --                  FROM dbo.Agencies
--  --                  WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency
--  --              ) AS Description,
--  --                     Fee AS Usd
--  --              FROM dbo.PaymentChecksAgentToAgent
--  --              WHERE FromAgency = @AgencyId 
--  --                    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
--  --                    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE)
--		--			  AND Fee > 0
--
--
--		--			  END
--
---- Payment checks
--         IF(@Type IS NULL
--            OR @Type = 6)
--             BEGIN
--                 INSERT INTO #Temp
--                        SELECT 7,
--                        t.Type,
--                               t.CreationDate,
--                               t.Description,
--                               SUM(t.Usd) AS Usd
--                        FROM
--                        (
--                            SELECT 'PAYMENT CHECKS' AS Type,
--                                   CAST(pc.Date AS DATE) AS CreationDate,
--                                   dbo.Agencies.Code+'' + ' '+CASE
--                                                                         WHEN dbo.ProviderTypes.Code = 'C02'
--                                                                              THEN ISNULL(
--                                                                                          (
--                                                                                           SELECT TOP 1 mt.Number
--                                                                                           FROM MoneyTransferxAgencyNumbers mt
--                                                                                           WHERE mt.AgencyId = pc.AgencyId
--                                                                                           AND mt.ProviderId = pc.ProviderId
--                                                                                            ), 'Not registered')
--                                                                                            ELSE dbo.Providers.Name
--                                                                                           END+' '+CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10))+' TO '+CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description,
--                                   Usd AS Usd
--                            FROM dbo.PaymentChecks pc
--                                 INNER JOIN dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId
--                                 INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
--                                 INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--                            WHERE((@FromDate IS NULL)
--                                  OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
--                                 AND ((@ToDate IS NULL)
--                                      OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
--                                 AND pc.AgencyId = @AgencyId
--                        ) t
--                        GROUP BY t.CreationDate,
--                                 t.Type,
--                                 t.Description;
--         END;
--
--
---- Payment checks fee
--         --IF(@Type IS NULL
--         --   OR @Type = 7)
--         --    BEGIN
--         --        INSERT INTO #Temp
--         --               SELECT t.Type,
--         --                      t.CreationDate,
--         --                      t.Description,
--         --                      SUM(t.Usd) AS Usd
--         --               FROM
--         --               (
--         --                   SELECT 'PAYMENT CHECKS FEE' AS Type,
--         --                          CAST(pc.Date AS DATE) AS CreationDate,
--         --                          dbo.Agencies.Code+' - '+dbo.Agencies.Name + ' ('+CASE
--         --                                                                WHEN dbo.ProviderTypes.Code = 'C02'
--         --                                                                     THEN ISNULL(
--         --                                                                                 (
--         --                                                                                  SELECT TOP 1 mt.Number
--         --                                                                                  FROM MoneyTransferxAgencyNumbers mt
--         --                                                                                  WHERE mt.AgencyId = pc.AgencyId
--         --                                                                                  AND mt.ProviderId = pc.ProviderId
--         --                                                                                   ), 'Number not registered')
--         --                                                                                   ELSE dbo.Providers.Name
--         --                                                                                  END+') '+CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10))+' TO '+CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description,
--         --                          Fee AS Usd
--         --                   FROM dbo.PaymentChecks pc
--         --                        INNER JOIN dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId
--         --                        INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
--         --                        INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--         --                   WHERE((@FromDate IS NULL)
--         --                         OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
--         --                        AND ((@ToDate IS NULL)
--         --                             OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
--         --                        AND pc.AgencyId = @AgencyId
--								 --AND Fee > 0
--         --               ) t
--         --               GROUP BY t.CreationDate,
--         --                        t.Type,
--         --                        t.Description;
--         --END;
--         
--		 
--		 SELECT *
--         FROM #Temp
--         ORDER BY RowIndex,
--				   CreationDate,
--                  [Type]
--                  ;
--         DROP TABLE #Temp;
--     END;





GO