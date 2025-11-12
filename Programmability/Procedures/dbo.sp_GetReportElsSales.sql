SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
CREATE PROCEDURE [dbo].[sp_GetReportElsSales] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  DECLARE @FromDateInitial AS DATETIME;
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
  SET @FromDateInitial = DATEADD(DAY, -1, @FromDate);


  DECLARE @agencyInitialBalance DECIMAL(18, 2)
  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @agencyInitialBalance = ISNULL((SELECT TOP 1
      InitialBalance
    FROM ElsxAgencyInitialBalances
    WHERE AgencyId = @AgencyId)
  , 0)

  SET @BalanceDetail = @agencyInitialBalance + ISNULL((SELECT
      SUM(CAST(BalanceDetail AS DECIMAL(18,2)))
    FROM dbo.FN_GenerateBalanceElsSales(@AgencyId, '1985-01-01', @FromDateInitial)),0)

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,TypeDetailId INT
   ,Transactions INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
--   ,Balance DECIMAL(18, 2)
  );




  INSERT INTO #Temp
    SELECT
      1 [Index]
     ,@AgencyId AgencyId
     ,CAST(@FromDateInitial AS Date) Date
     ,'INITIAL BALANCE' Description
     ,'INITIAL BALANCE' Type
     ,0 TypeId
     ,0 TypeDetailId
     ,0 Transactions
     ,0 Debit
        ,0 Credit
--     ,@BalanceDetail * -1 Credit
     ,@BalanceDetail BalanceDetail
--     ,@BalanceDetail

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateBalanceElsSales(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    [Index];


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18,2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal

  FROM #Temp T1

  DROP TABLE #Temp

END


GO