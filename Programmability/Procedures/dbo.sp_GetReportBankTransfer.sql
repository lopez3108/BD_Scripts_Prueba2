SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:21-09-2023
--CAMBIOS EN 5387,Refactorizacion de reporte banks

--Last update by JT/05-06-2025 TASK 6562 Order fixed
CREATE PROCEDURE [dbo].[sp_GetReportBankTransfer] (@BankAccountId INT,
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
  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,BankAccountId INT
   ,PaymentBanksToBankId INT
   ,FromBankAccountId INT
   ,ToBankAccountId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,AccountNumber VARCHAR(1000)
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)

  )


  INSERT INTO #Temp
    SELECT
      1
     ,Tob.BankAccountId
     ,pf.PaymentBanksToBankId
     ,pf.FromBankAccountId
     ,pf.ToBankAccountId
     ,CAST(pf.Date AS DATE) AS DATE
     ,'TRANSFER TO ' Type
     ,'CLOSING DAILY' Description
     ,0 TypeId
     ,'**** ' + Tob.AccountNumber AS AccountNumber
     ,pf.USD AS Credit
     ,0 AS Debit
     ,SUM(ISNULL(pf.USD, 0)) AS BalanceDetail
    FROM [PaymentBanksToBanks] pf
    INNER JOIN BankAccounts Tob
      ON Tob.BankAccountId = pf.ToBankAccountId
    INNER JOIN Bank Toba
      ON Tob.BankId = Toba.BankId
    WHERE (pf.FromBankAccountId = @BankAccountId
    OR pf.ToBankAccountId = @BankAccountId
    OR @BankAccountId IS NULL)
    AND (CAST(pf.Date AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(pf.Date AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY Tob.BankAccountId
            ,pf.PaymentBanksToBankId
            ,pf.FromBankAccountId
            ,pf.ToBankAccountId
            ,Tob.AccountNumber
            ,pf.USD
            ,CAST(pf.Date AS DATE)
    UNION ALL
    SELECT
      2
     ,Fromb.BankAccountId
     ,pf.PaymentBanksToBankId
     ,pf.FromBankAccountId
     ,pf.ToBankAccountId
     ,CAST(pf.Date AS DATE) AS DATE
     ,'TRANSFER FROM ' Type
     ,'CLOSING DAILY' Description
     ,1 TypeId
     ,'**** ' + Fromb.AccountNumber AS AccountNumber
     ,0 AS Debit
     ,pf.USD AS Credit
     ,-SUM(ISNULL(pf.USD, 0)) AS BalanceDetail
    FROM [PaymentBanksToBanks] pf
    INNER JOIN BankAccounts Fromb
      ON Fromb.BankAccountId = pf.FromBankAccountId
    INNER JOIN Bank fromba
      ON Fromb.BankId = fromba.BankId
    WHERE (pf.FromBankAccountId = @BankAccountId
    OR pf.ToBankAccountId = @BankAccountId
    OR @BankAccountId IS NULL)
    AND (CAST(pf.Date AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(pf.Date AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY Fromb.BankAccountId
            ,pf.PaymentBanksToBankId
            ,pf.FromBankAccountId
            ,pf.ToBankAccountId
            ,Fromb.AccountNumber
            ,pf.USD
            ,CAST(pf.Date AS DATE);


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1
  ORDER BY T1.PaymentBanksToBankId, T1.Date, T1.[Index]
  DROP TABLE #Temp

END
GO