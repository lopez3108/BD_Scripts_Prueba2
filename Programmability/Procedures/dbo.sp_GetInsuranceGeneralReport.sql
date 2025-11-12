SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-03 CB/6023: Insurance report general
-- 2024-11-17 JF/6023: Insurance report general

CREATE PROCEDURE [dbo].[sp_GetInsuranceGeneralReport] (
@AgencyId INT,
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
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)

DECLARE @agencyInitialBalance DECIMAL(18,2)
SET @agencyInitialBalance = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18,2))) FROM dbo.FN_GenerateInsuranceReport(@AgencyId, @ProviderId, '1985-01-01', @initialBalanceFinalDate,@InsuranceTypeIds)),0)

  CREATE TABLE #Temp (
    [ID] INT IDENTITY(1,1),
    [Index] INT
 ,[Group] INT
 ,[Date] DATETIME
 ,[Type] VARCHAR(40)
  ,[Description] VARCHAR(70)
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
	  ,CAST(@initialBalanceFinalDate AS DATE) as CreationDate
	   ,'INITIAL BALANCE'
     ,'-'
	 ,0
     ,NULL AS Debit
     ,NULL AS Credit
	 ,@agencyInitialBalance
	  UNION ALL
        SELECT *
        FROM dbo.FN_GenerateInsuranceReport(@AgencyId, @ProviderId, @FromDate, @ToDate,@InsuranceTypeIds)
        ORDER BY CreationDate, 
                 [Index],
				 [Group]
  
  SELECT 
				 *,
				 (
            SELECT   ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18,2))), 0)
            FROM    #Temp T2
            WHERE T2.ID <= T1.ID
        ) RunningSum
				 FROM #Temp T1
      ORDER BY ID ASC
				 DROP TABLE #Temp

END;








GO