SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:11-10-2023
--CAMBIOS EN 5424, Refactoring reporte de tax commissions

--LASTUPDATEDBY: Sergio
--LASTUPDATEDON: 22-05-2024
--CAMBIOS EN 5804, se agrega transactions

CREATE PROCEDURE [dbo].[sp_GetReportPayrollCommissions] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
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
    FROM [dbo].fn_GeneratePayrollCommissionsInitialReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[Type] VARCHAR(30)
   ,CreationDate DATETIME
   ,[Description] VARCHAR(100)
   ,Transactions INT  -- Nueva columna - sergio
   ,Usd DECIMAL(18, 2) NULL
   ,Commission DECIMAL(18, 2) NULL
   ,CreditCommission DECIMAL(18, 2) NULL
   ,[Month] INT NULL
   ,[Year] INT NULL
   ,Balance DECIMAL(18, 2)

  )
  --       dbo.fn_CalculatePayrollCommissionsInitialBalance(@AgencyId, @initialBalanceFinalDate),

  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,'INITIAL BALANCE' Type
     ,CAST(@initialBalanceFinalDate AS DATE) CreationDate
     ,'INITIAL BALANCE' Description
     ,'-'AS Transactions
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,@BalanceDetail Balance


    UNION ALL

    SELECT
      *
    FROM [dbo].fn_GeneratePayrollCommissionsInitialReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY CreationDate,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Balance AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID
      )
    BalanceFinal
  FROM #Temp T1

  ORDER BY CreationDate,
  [Index];
  DROP TABLE #Temp;


END











---------------------------------------

--     BEGIN
--         IF(@FromDate IS NULL)
--             BEGIN
--                 SET @FromDate = DATEADD(day, -10, @Date);
--                 SET @ToDate = @Date;
--         END;
--DECLARE @initialBalanceFinalDate DATETIME
--SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
--         CREATE TABLE #Temp
--         ([Index]       INT,
--          [Type]        VARCHAR(30),
--
--          CreationDate  DATETIME,
--          [Description] VARCHAR(100),
--          Usd           DECIMAL(18, 4) NULL,
--		  Commission           DECIMAL(18, 4) NULL,
--		  CreditCommission           DECIMAL(18, 2) NULL,
--		  [Month] INT NULL,
--		  [Year] INT NULL
--         );
--
--
---- Initial cash balance
--         INSERT INTO #Temp
--                SELECT 
--				1,
--                       'INITIAL BALANCE',
--                       CAST(@initialBalanceFinalDate AS DATE),
--                       'INITIAL BALANCE',
--					   dbo.fn_CalculatePayrollCommissionsInitialBalance(@AgencyId, @initialBalanceFinalDate),
--					   NULL,
--					   NULL,
--					   NULL,
--					   NULL
--                       
--
--
---- Daily
--
--         INSERT INTO #Temp
--SELECT       
--2,
--t.Type,
--t.CreationDate,
--t.Description,
--SUM(t.Usd),
--SUM(t.Commission),
--NULL,
--NULL,
--NULL
--FROM  ( SELECT
--'CLOSING CHECKS' as Type,
--CAST(dbo.ChecksEls.CreationDate AS DATE) as CreationDate,
--'PAYROLL CHECKS' as Description,
--ISNULL(dbo.ChecksEls.Amount, 0) AS Usd,
--ISNULL((dbo.ChecksEls.Amount * dbo.ChecksEls.Fee / 100), 0) AS Commission
--        FROM  dbo.ChecksEls INNER JOIN dbo.ProviderTypes ON
--		dbo.ProviderTypes.ProviderTypeId = dbo.ChecksEls.ProviderTypeId
--						 WHERE 
--						 dbo.ProviderTypes.Code = 'C03' AND
--						 dbo.ChecksEls.AgencyId = @AgencyId 
--						AND CAST(dbo.ChecksEls.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ChecksEls.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--
--  ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
--
-- 
---- Commissions
--
--         INSERT INTO #Temp
--SELECT        
--3,
--'COMMISSIONS',
--CAST(dbo.ProviderCommissionPayments.CreationDate as DATE),
--'COMMISSIONS ',
--NULL,
--NULL,
--Usd,
--dbo.ProviderCommissionPayments.Month,
--dbo.ProviderCommissionPayments.Year
--FROM            dbo.ProviderCommissionPayments INNER JOIN
--                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
--                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--						 WHERE 
--						 dbo.ProviderTypes.Code = 'C03' AND
--						 dbo.ProviderCommissionPayments.AgencyId = @AgencyId 
--						AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--
--
--						 
--
--
--         SELECT *
--         FROM #Temp
--         ORDER BY CreationDate,
--                  [Index];
--         DROP TABLE #Temp;
--     END;





GO