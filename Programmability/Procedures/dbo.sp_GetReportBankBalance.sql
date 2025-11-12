SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5387,Refactorizacion de reporte banks
CREATE PROCEDURE [dbo].[sp_GetReportBankBalance] (@BankAccountId INT,
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


  -- INITIAL BALANCE
  DECLARE @InitialBalance DECIMAL(18, 2)
  SET @InitialBalance = ISNULL((SELECT TOP 1
      BankAccounts.InitialBalance
    FROM BankAccounts
    WHERE BankAccountId = @BankAccountId)
  , 0)


  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)



  DECLARE @Balance DECIMAL(18, 2)
  SET @Balance = @InitialBalance + ISNULL((SELECT
      SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
    FROM dbo.FN_GenerateBankBalance(@BankAccountId, '1985-01-01', @initialBalanceFinalDate))
  , 0)



  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,BankAccountId INT
   ,PaymentBanksToBanks INT
   ,Date DATETIME
   ,PaymentType VARCHAR(1000)
   ,Number VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,TypeId INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2) NULL
  )

  INSERT INTO #Temp

    SELECT
      1 [Index]
     ,0 BankAccountId
     ,0 PaymentBanksToBanks
     ,CAST(@initialBalanceFinalDate AS Date) Date
     ,'INITIAL BALANCE' PaymentType
     ,'' Number
     ,'INITIAL BALANCE' Type
     ,'INITIAL BALANCE' Description
     ,1 TypeId
     ,0 Debit
     ,0 Credit
     ,@Balance BalanceDetail
    --                         ,@Balance Balance

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateBankBalance(@BankAccountId, @FromDate, @ToDate)
    ORDER BY Date,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    RunningSum

  FROM #Temp T1

  DROP TABLE #Temp
END;






GO