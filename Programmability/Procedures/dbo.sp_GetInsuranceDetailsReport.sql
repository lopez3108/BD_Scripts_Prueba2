SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-01 CB/6023: Insurance report details
-- 2024-10-01 JT/6125: Insurance report details show - in initial balance
-- 2024-10-31  JT/6137: Insurance report details fix order payments, and add new colum policy number
-- 2024-10-03 CB/6023: Insurance report general
-- 2024-11-17 JF/6191: Ajustes reporte insurance
CREATE PROCEDURE [dbo].[sp_GetInsuranceDetailsReport] (@AgencyId INT,
@ProviderId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@InsuranceTypeIds VARCHAR(100) = NULL)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;



  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)

  DECLARE @agencyInitialBalance DECIMAL(18, 2)
  SET @agencyInitialBalance = ISNULL((SELECT
      SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
    FROM dbo.FN_GenerateInsuranceDetailReport(@AgencyId, @ProviderId, '1985-01-01', @initialBalanceFinalDate,@InsuranceTypeIds))
  , 0)

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[Group] INT
   ,IdGroup INT
   ,[Date] DATETIME
   ,[Provider] VARCHAR(50)
   ,[PolicyNumber] VARCHAR(50)

   ,[Insurance] VARCHAR(50)
   ,[Type] VARCHAR(40)
   ,[Employee] VARCHAR(70)
   ,[Transactions] INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2) NULL
   ,BalanceDetail DECIMAL(18, 2)
  );

  ---- Initial balance
  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,0 [Group]
     ,0 IdGroup
     ,CAST(@initialBalanceFinalDate AS DATE) AS CreationDate
     ,'-'
     ,'-'
     ,'-'
     ,'INITIAL BALANCE'
     ,'-'
     ,'-'
     ,NULL AS Debit
     ,NULL AS Credit
     ,@agencyInitialBalance
    UNION ALL
    SELECT
      *
    FROM dbo.FN_GenerateInsuranceDetailReport(@AgencyId, @ProviderId, @FromDate, @ToDate,@InsuranceTypeIds)
    ORDER BY CreationDate, [Index],
    IdGroup,
    [Group]

  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    RunningSum
  FROM #Temp T1
  ORDER BY ID ASC
  DROP TABLE #Temp

END;










GO