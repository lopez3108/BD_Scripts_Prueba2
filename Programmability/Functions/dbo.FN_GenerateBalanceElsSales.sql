SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: ROMARIO
--LASTUPDATEDON:05-12-2023
--se realiza cambio en base a la task 5534 romario

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)

--LASTUPDATEDBY: JT
--LASTUPDATEDON:19-03-2024
--CAMBIOS EN 5747 (Discriminar pagos de banco en el reporte de vehicle services )
CREATE   FUNCTION [dbo].[FN_GenerateBalanceElsSales] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)



RETURNS @result TABLE (
  [Index] INT
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
)
AS


BEGIN
  --ESTADO DELETE OTHER Y CASH
  DECLARE @PaymentOthersStatusId INT;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')

  INSERT INTO @result
    SELECT
      2
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'CITY STICKER' Type
     ,1 TypeId
     ,1 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    FROM CityStickers S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
      3
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'COUNTY TAX' Type
     ,1 TypeId
     ,2 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    FROM CountryTaxes S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
      4
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'PARKING TICKET ELS' Type
     ,1 TypeId
     ,4 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) + SUM(ISNULL(S.Fee2, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) + SUM(ISNULL(S.Fee2, 0)) AS BalanceDetail
    FROM ParkingTickets S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
      5
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'REGISTRATION RENEWALS' Type
     ,1 TypeId
     ,5 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    FROM PlateStickers S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
      6
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'TITLE AND PLATES' Type
     ,1 TypeId
     ,7 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    FROM Titles S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE S.ProcessAuto = 1
    AND A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
      7
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'TITLE INQUIRY' Type
     ,1 TypeId
     ,8 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    FROM TitleInquiry S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result --Credit payments
    SELECT
      8
     ,S.AgencyId
     ,CAST(S.FromDate AS DATETIME) AS DATE
     ,'**' + RIGHT(Ba.AccountNumber, 4) + ' ' + B.Name Description
     ,'BANK PAYMENT' Type
     ,2 TypeId
     ,1 TypeDetailId
     ,1 Transactions
     ,0 AS Debit
     ,(ISNULL(C.USD, 0)) AS Credit
     ,-(ISNULL(C.USD, 0)) AS BalanceDetail
    FROM ConciliationELS S
    INNER JOIN ConciliationELSDetails C
      ON S.ConciliationELSId = C.ConciliationELSId
    INNER JOIN BankAccounts Ba
      ON Ba.BankAccountId = S.BankAccountId
    INNER JOIN Bank B
      ON Ba.BankId = B.BankId
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE S.IsCredit = 1
    AND A.AgencyId = @AgencyId
    AND (CAST(S.FromDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.FromDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
        --Commented in task 5747 Discriminar pagos de banco en el reporte de vehicle services 

  --    GROUP BY S.AgencyId
  --         
  --            ,Ba.AccountNumber
  --            ,B.Name
  --            ,CAST(S.FromDate AS DATE)


  INSERT INTO @result --Debit payments
    SELECT
      9
     ,S.AgencyId
     ,CAST(S.FromDate AS DATETIME) AS DATE
     ,'**' + RIGHT(Ba.AccountNumber, 4) + ' ' + B.Name Description
     ,'BANK PAYMENT' Type
     ,2 TypeId
     ,2 TypeDetailId
     ,1 Transactions
     ,(ISNULL(C.USD, 0)) AS Debit
     ,0 AS Credit
     ,(ISNULL(C.USD, 0)) AS BalanceDetail
    FROM ConciliationELS S
    INNER JOIN ConciliationELSDetails C
      ON S.ConciliationELSId = C.ConciliationELSId
    INNER JOIN BankAccounts Ba
      ON Ba.BankAccountId = S.BankAccountId
    INNER JOIN Bank B
      ON Ba.BankId = B.BankId
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE S.IsDebit = 1
    AND A.AgencyId = @AgencyId
    AND (CAST(S.FromDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.FromDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    --Commented in task 5747 Discriminar pagos de banco en el reporte de vehicle services 
  --    GROUP BY 
  --            S.AgencyId
  --           
  --            ,Ba.AccountNumber
  --            ,B.Name
  --            ,CAST(S.FromDate AS DATE)



  INSERT INTO @result --Credit OTHER payments

    SELECT
      10
     ,S.AgencyId
     ,CAST(S.Date AS DATE) AS DATE
     ,'OTHER PAYMENTS CREDIT' Description
     ,'PAYMENTS' Type
     ,2 TypeId
     ,9 TypeDetailId
     ,1 Transactions
     ,0 AS Debit
     ,SUM(ISNULL(S.USD, 0)) AS Credit
     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    --     ,SUM(ISNULL(S.USD, 0)) AS BalanceDetail  se realiza cambio en base a la task 5534 romario
    FROM PaymentOthers S
    INNER JOIN dbo.Providers
      ON S.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND PaymentOtherStatusId != @PaymentOthersStatusId)
    AND dbo.ProviderTypes.Code = 'C05'--ELS
    AND S.IsDebit = 1
    AND S.AgencyId = @AgencyId
    AND (CAST(S.Date AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.Date AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,CAST(S.date AS DATE)
            ,Description

  INSERT INTO @result --Debit payments
    SELECT
      11
     ,S.AgencyId
     ,CAST(S.Date AS DATE) AS DATE
     ,'OTHER PAYMENTS DEBIT' Description
     ,'PAYMENTS' Type
     ,2 TypeId
     ,9 TypeDetailId
     ,1 Transactions
     ,SUM(ISNULL(S.USD, 0)) AS Debit
     ,0 AS Credit
     ,SUM(ISNULL(S.USD, 0)) AS BalanceDetail
    --     ,-SUM(ISNULL(S.USD, 0)) AS BalanceDetail  se realiza cambio en base a la task 5534 romario
    FROM PaymentOthers S
    INNER JOIN dbo.Providers
      ON S.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND PaymentOtherStatusId != @PaymentOthersStatusId)
    AND dbo.ProviderTypes.Code = 'C05'--ELS
    AND S.IsDebit = 0
    AND S.AgencyId = @AgencyId
    AND (CAST(S.Date AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.Date AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,CAST(S.date AS DATE)
            ,Description



  RETURN;

END
GO