SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:21-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
-- =============================================
-- Author:      JF
-- Create date: 14/07/2024 5:15 p. m.
-- Database:    copiaDevtest
-- Description:  task 5916 Aplicar fee a los para los VEHICLE SERVICES RETURNED
-- =============================================


CREATE   FUNCTION [dbo].[FN_GenerateBalanceElsCommissionsELS] (@AgencyId INT,
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
 ,FeeEls DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
 
)
AS

BEGIN

  INSERT INTO @result
    SELECT
    2,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'CITY STICKER' Type
     ,1 TypeId
     ,1 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(S.FeeEls, 0)) AS Credit
     ,SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
    3,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'COUNTY TAX' Type
     ,1 TypeId
     ,2 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(S.FeeEls, 0)) AS Credit
     ,SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
    4,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'PARKING TICKET ELS' Type
     ,1 TypeId
     ,4 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(S.FeeEls, 0)) AS Credit
     ,SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
    5,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'REGISTRATION RENEWALS' Type
     ,1 TypeId
     ,5 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(S.FeeEls, 0)) AS Credit
     ,SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
    6,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'TITLE AND PLATES' Type
     ,1 TypeId
     ,7 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(S.FeeEls, 0)) AS Credit
     ,SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
    7,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'TITLE INQUIRY' Type
     ,1 TypeId
     ,8 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(S.FeeEls, 0)) AS Credit
     ,SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
  INSERT INTO @result --IsCommissionPayments payments

    SELECT
    8,
      S.AgencyId
     ,CAST(S.FromDate AS DATE) AS DATE
     ,'**' + RIGHT(Ba.AccountNumber, 4) + ' ' + B.Name Description
     ,'BANK PAYMENT' Type
     ,2 TypeId
     ,1 TypeDetailId
     ,0 Transactions
     ,SUM(ISNULL(C.Usd, 0)) AS Debit
     ,0 AS Credit
     ,-SUM(ISNULL(C.USD, 0)) AS BalanceDetail
    FROM ConciliationELS S
    INNER JOIN ConciliationELSDetails C
      ON S.ConciliationELSId = C.ConciliationELSId
    INNER JOIN BankAccounts Ba
      ON Ba.BankAccountId = S.BankAccountId
    INNER JOIN Bank B
      ON Ba.BankId = B.BankId
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE S.IsCommissionPayments = 1
    AND A.AgencyId = @AgencyId
    AND (CAST(S.FromDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.FromDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.ConciliationELSId
            ,S.AgencyId
            ,A.Name
            ,Ba.AccountNumber
            ,B.Name
            ,CAST(S.FromDate AS DATE)
            
             INSERT INTO @result
    SELECT
    9,
      re.AgencyId
     ,CAST(re.CreatedOn AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,ie.Description + ' - ' + 'RETURNED' Type
     ,1 TypeId
     ,1 TypeDetailId
     ,COUNT(*) Transactions
     ,0 AS FeeEls
     ,SUM(ISNULL(re.Fee, 0)) AS Credit
     ,SUM(ISNULL(re.Fee, 0)) AS BalanceDetail
    FROM ReturnsELS re
    INNER JOIN Agencies A
      ON A.AgencyId = re.AgencyId
      INNER JOIN InventoryELS ie ON re.InventoryELSId = ie.InventoryELSId
    WHERE A.AgencyId = @AgencyId AND re.ReturnType = 1
    AND (CAST(re.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(re.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY re.AgencyId
            ,A.Name
            ,CAST(re.CreatedOn AS DATE)
            ,ie.Description

  RETURN;
END
GO