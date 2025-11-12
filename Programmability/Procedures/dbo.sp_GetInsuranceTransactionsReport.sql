SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 19/11/2024 11:17 p. m.
-- Database:    developing
-- Description: task 6207 Nuevo reporte insurance
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetInsuranceTransactionsReport] (@AgencyId INT,
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
    FROM dbo.FN_GenerateInsuranceTransactionsReport(@AgencyId, @ProviderId, '1985-01-01', @initialBalanceFinalDate,@InsuranceTypeIds))
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
   ,[ClientName] VARCHAR(70)
   ,[Transactions] INT
   ,Credit DECIMAL(18, 2) NULL
   ,BalanceDetail DECIMAL(18, 2)

  );

  ---- Initial balance
  INSERT INTO #Temp
--    SELECT
--      0 [Index]
--     ,0 [Group]
--     ,0 IdGroup
--     ,CAST(@initialBalanceFinalDate AS DATE) AS CreationDate
--     ,'-'
--     ,'-'
--     ,'-'
--     ,'-'
--     ,'INITIAL BALANCE'
--     ,'-'
--     ,'-'
--     ,NULL AS Credit
--     ,@agencyInitialBalance
--    UNION ALL
    SELECT
      *
    FROM dbo.FN_GenerateInsuranceTransactionsReport(@AgencyId, @ProviderId, @FromDate, @ToDate,@InsuranceTypeIds)
    ORDER BY  [Index],
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
  ORDER BY [Date], ID ASC
  DROP TABLE #Temp

END;











GO