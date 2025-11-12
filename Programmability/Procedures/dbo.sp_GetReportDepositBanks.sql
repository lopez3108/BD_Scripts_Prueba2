SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5387,Refactorizacion de reporte banks
CREATE PROCEDURE [dbo].[sp_GetReportDepositBanks] (@BankAccountId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
 IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
        END;

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,BankAccountId INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,Amount DECIMAL(18, 2)

  )

  INSERT INTO #Temp

    SELECT
      1
     ,p.BankAccountId
     ,CAST(p.Date AS DATE) AS DATE
     ,'PAYMENTS BANKS' Type
     ,CASE
        WHEN CAST(p.IsDebitCredit AS BIT) = CAST(1 AS BIT) THEN 'DEPOSIT FROM ' + a.Code + ' - ' + a.Name
        ELSE (SELECT TOP 1
              CAST(pb.Note AS VARCHAR(20))
            FROM PaymentBankNotes pb
            WHERE pb.PaymentBankId = p.PaymentBankId)
      END AS Description
     ,p.USD AS Amount
    FROM [PaymentBanks] p
    INNER JOIN BankAccounts Ba
      ON Ba.BankAccountId = p.BankAccountId
    INNER JOIN Bank B
      ON Ba.BankId = B.BankId
    LEFT JOIN Agencies a
      ON a.AgencyId = p.AgencyId
    WHERE p.BankAccountId = @BankAccountId
    AND (CAST(p.Date AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(p.Date AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY p.BankAccountId
            ,p.USD
            ,CAST(p.Date AS DATE)
            ,PaymentBankId
            ,p.IsDebitCredit
            ,a.Code
            ,a.Name;


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Amount AS DECIMAL(18,2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1
  DROP TABLE #Temp

END

GO