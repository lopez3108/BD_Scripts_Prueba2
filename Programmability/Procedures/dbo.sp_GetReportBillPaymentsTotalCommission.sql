SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-19 DJ/5731: Created to add initial balance to report

CREATE PROCEDURE [dbo].[sp_GetReportBillPaymentsTotalCommission] (@AgencyId INT,
@ProviderId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN

CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,OperationTypeId INT
   ,ProviderCommissionPaymentId INT NULL
   ,ProviderId INT NULL
   ,CreationDate DATETIME
   ,[Type] VARCHAR(100) 
   ,[Description] VARCHAR(100)
   ,[Month] INT
   ,[Year] INT
   ,[Debit] DECIMAL(18, 2) NULL
   ,[Credit] DECIMAL(18, 2) NULL
   ,[Balance] DECIMAL(18, 2) NULL
  )

  IF (@FromDate IS NULL)
  BEGIN

    SET @FromDate = DATEADD(DAY, -10, @Date)
    SET @ToDate = @Date

  END

  DECLARE @agencyInitialBalance DECIMAL(18,2)

DECLARE @initialBalanceFinalDate DATETIME
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)


SET @agencyInitialBalance = ISNULL((SELECT SUM(CAST([Balance] AS DECIMAL(18,2))) FROM dbo.FN_GetTopUpPaymentsTotalCommissionReport(@AgencyId, @ProviderId, '2018-01-01', @initialBalanceFinalDate)),0)
		

		INSERT INTO #Temp
               SELECT 
			   0 OperationTypeId, 
			   NULL,
			   NULL,
			   CAST(@initialBalanceFinalDate AS DATE) CreationDate, 
                      'INITIAL BALANCE' [Type], 
                      'INITIAL BALANCE' [Description], 
					  DATEPART(month, @initialBalanceFinalDate) [Month],
					  DATEPART(YEAR, @initialBalanceFinalDate) [Year],
                   NULL Debit, 
                      NULL Credit,
					  @agencyInitialBalance Balance

UNION ALL

                SELECT * FROM 
				dbo.FN_GetTopUpPaymentsTotalCommissionReport(@AgencyId, @ProviderId, @FromDate, @ToDate)
        ORDER BY   [CreationDate],[Type]


  SELECT
    *
   ,(SELECT
       ISNULL( SUM(CAST(Balance AS DECIMAL(18,2))),0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    RunningSum
  FROM #Temp T1


  DROP TABLE #Temp


END

GO