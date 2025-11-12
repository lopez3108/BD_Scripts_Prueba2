SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5387,Refactorizacion de reporte banks

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

-- 2024-03-13 5697: Returned checks registers missed ..
-- 2024-08-07  JF/5905: omisión pagada en 0.00 debe reflejarse en el reporte
-- 2024-0807 DJ/5991: Added payment type to deposit refund operation
-- 2024-09-24 DJ/6020: Added insurance ACH operations
-- 2024-10-15 Luis/6091 Change "RETURN PAYMENT" for "PAYMENT OF RETURNED CHECK" a new modification is entered "RETURNED CHECK PAYMENT"
-- 2024-10-28 JT/6114: Insurance payments ach, always show alone
-- 2024-10-28 JT/6130: Insurance movements descriptions
-- 2024-12-10 DJ/6236: Agregar valor transaction fee al reporte de trafic tickets  y banks
-- 2025-01-27 JF /6315: REPORTES (CARD PAYMENTS Y BANKS) - TYPE & DESCRIPTION no muestra tipo de servicio correcto
-- 2025-01-05 DJ/6329: Ajuste pagos ACH
-- 2025-03-18 DJ/6400: Identificación de Débitos y Créditos en el Reporte de BANKS
-- 2025-04-07 DJ/6424: Opción ACH - COMMISSION PAYMENT ya no será tenida en cuenta
-- 2025-06-10 JT/6581: Corrección pagos ach - reporte bancos
-- 2025-06-12 JT/6518: Fix error getting tenant of rent payments
-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT
-- 2025-10-08 jf/6775: Permitir pagos con créditos y débitos

CREATE FUNCTION [dbo].[FN_GenerateBankBalance] (@BankAccountId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL) --1 = INITIAL BALANDE 2= ANOTHER
RETURNS @Result TABLE (
  [Index] INT
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
AS

BEGIN

INSERT INTO @Result -- C BILL PAYMENTS 
  SELECT
    2
   ,CB.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(CB.Date AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CB.IsCredit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END) Type
   ,REPLACE(A.Code + ' - ' + P.Name, CHAR(13) + CHAR(10), ' ') Description
   ,1 TypeId
   ,(CASE
      WHEN CB.IsCredit = 0 THEN 0
      ELSE SUM(ISNULL(CB.USD, 0))
    END) Debit
   ,(CASE
      WHEN CB.IsCredit = 1 THEN 0
      ELSE SUM(ISNULL(CB.USD, 0))
    END) Credit
   ,(CASE
      WHEN CB.IsCredit = 0 THEN -SUM(ISNULL(CB.USD, 0))
      ELSE SUM(ISNULL(CB.USD, 0))
    END) BalanceDetail
  FROM ConciliationBillPayments CB
  INNER JOIN Agencies A
    ON A.AgencyId = CB.AgencyId
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CB.BankAccountId
  INNER JOIN Providers P
    ON CB.ProviderId = P.ProviderId
  WHERE (CB.BankAccountId = @BankAccountId)
  AND (CAST(CB.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CB.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CB.ConciliationBillPaymentId
          ,CB.BankAccountId
          ,Fromb.AccountNumber
          ,CB.IsCredit
          ,P.Name
          ,A.Code
          ,CAST(CB.Date AS DATE)


INSERT INTO @Result -- ELS (VEHICLE SERVICE)
  SELECT
    3
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(CE.ToDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CE.IsCredit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END) Type
   ,REPLACE(A.Code + ' - ' + 'VEHICLE SERVICES', CHAR(13) + CHAR(10), ' ') Description
   ,

    --'ELS' AS Description, 
    2 TypeId
   ,(CASE
      WHEN CE.IsDebit = 1 THEN 0
      ELSE SUM(ISNULL(ED.Usd, 0))
    END) Debit
   ,(CASE
      WHEN CE.IsCredit = 1 THEN 0
      ELSE SUM(ISNULL(ED.Usd, 0))
    END) Credit
   ,(CASE
      WHEN CE.IsCredit = 0 THEN -SUM(ISNULL(ED.Usd, 0))
      ELSE SUM(ISNULL(ED.Usd, 0))
    END) BalanceDetail
  FROM ConciliationELS CE
  INNER JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CE.BankAccountId
  INNER JOIN ConciliationELSDetails ED
    ON ED.ConciliationELSId = CE.ConciliationELSId
  WHERE (IsCommissionPayments = 0)
  AND (CE.BankAccountId = @BankAccountId)
  AND (CAST(CE.ToDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CE.ToDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CE.ConciliationELSId
          ,CE.BankAccountId
          ,A.Code
          ,Fromb.AccountNumber
          ,CE.IsCredit
          ,CE.IsDebit
          ,CAST(CE.CreationDate AS DATE)
          ,CAST(CE.ToDate AS DATE)



INSERT INTO @Result

  SELECT
    4
   ,CS.BankAccountId
   , -- C SALESTAXES
    0 AS PaymentBanksToBanks
   ,CAST(CS.Date AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CS.IsCredit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END) Type
   ,REPLACE(A.Code + ' - ' + 'SALES TAXES', CHAR(13) + CHAR(10), ' ') Description
   ,
    --' SALES TAXES' AS Description, 
    4 TypeId
   ,(CASE
      WHEN CS.IsCredit = 0 THEN 0
      ELSE SUM(ISNULL(CS.Usd, 0))
    END) Debit
   ,(CASE
      WHEN CS.IsCredit = 1 THEN 0
      ELSE SUM(ISNULL(CS.Usd, 0))
    END) Credit
   ,(CASE
      WHEN CS.IsCredit = 0 THEN -SUM(ISNULL(CS.Usd, 0))
      ELSE SUM(ISNULL(CS.Usd, 0))
    END) BalanceDetail
  FROM ConciliationSalesTaxes CS
  INNER JOIN Agencies A
    ON CS.AgencyId = A.AgencyId
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CS.BankAccountId
  WHERE (CS.BankAccountId = @BankAccountId)
  AND (CAST(CS.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CS.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CS.BankAccountId
          ,CS.ConciliationSalesTaxId
          ,A.Code
          ,Fromb.AccountNumber
          ,CS.IsCredit
          ,CAST(CS.Date AS DATE)


INSERT INTO @Result  -- C OTHERS o EXPENSES
  SELECT
    5
   ,CO.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(CO.Date AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CO.IsCredit = 0 THEN 'CREDIT'
      ELSE 'DEBIT'
    END) Type
   ,
    --CT.Description AS Description,
    CASE
      WHEN A.AgencyId IS NULL THEN CT.Description
      ELSE REPLACE(A.Code + ' - EXPENSE ' + '(' + CT.Description + ')', CHAR(13) + CHAR(10), ' ')
    END Description
   ,5 TypeId
   ,(CASE
      WHEN CO.IsCredit = 1 THEN SUM(ISNULL(CO.Usd, 0))
      ELSE 0
    END) Debit
   ,(CASE
      WHEN CO.IsCredit = 0 THEN SUM(ISNULL(CO.Usd, 0))
      ELSE 0
    END) Credit
   ,(CASE
      WHEN CO.IsCredit = 1 THEN SUM(ISNULL(CO.Usd, 0))
      ELSE -SUM(ISNULL(CO.Usd, 0))
    END) BalanceDetail
  FROM ConciliationOthers CO
  LEFT JOIN Agencies A
    ON CO.AgencyId = A.AgencyId
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CO.BankAccountId
  INNER JOIN ConciliationOtherTypes CT
    ON CT.ConciliationOtherTypeId = CO.ConciliationOtherTypeId
  WHERE (CO.BankAccountId = @BankAccountId)
  AND (CAST(CO.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CO.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CO.BankAccountId
          ,A.AgencyId
          ,A.Code
          ,CO.ConciliationOtherId
          ,Fromb.AccountNumber
          ,CO.IsCredit
          ,CT.Description
          ,CAST(CO.Date AS DATE)


INSERT INTO @Result
  SELECT
    6
   ,CV.BankAccountId
   , -- VENTRA 
    0 AS PaymentBanksToBanks
   ,CAST(CV.Date AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CV.IsCredit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END) Type
   ,
    --'VENTRA' AS Description, 
    REPLACE(A.Code + ' - ' + 'VENTRA', CHAR(13) + CHAR(10), ' ') Description
   ,6 TypeId
   ,(CASE
      WHEN CV.IsCredit = 0 THEN 0
      ELSE SUM(ISNULL(CV.Usd, 0))
    END) Debit
   ,(CASE
      WHEN CV.IsCredit = 1 THEN 0
      ELSE SUM(ISNULL(CV.Usd, 0))
    END) Credit
   ,(CASE
      WHEN CV.IsCredit = 0 THEN -SUM(ISNULL(CV.Usd, 0))
      ELSE SUM(ISNULL(CV.Usd, 0))
    END) BalanceDetail
  FROM ConciliationVentras CV
  INNER JOIN Agencies A
    ON CV.AgencyId = A.AgencyId
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CV.BankAccountId
  WHERE (CV.BankAccountId = @BankAccountId)
  AND (CAST(CV.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CV.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CV.BankAccountId
          ,CV.ConciliationVentraId
          ,Fromb.AccountNumber
          ,A.Code
          ,CV.IsCredit
          ,CAST(CV.Date AS DATE)


INSERT INTO @Result
  SELECT
    7
   ,PF.FromBankAccountId
   , -- TOBANK TRANSFER
    PF.PaymentBanksToBankId AS PaymentBanksToBanks
   ,CAST(PF.Date AS DATE) AS DATE
   ,'TRANSFER' PaymentType
   ,'**** ' + Tob.AccountNumber AS Number
   ,'DEBIT' Type
   ,'TO ' + '**** ' + Tob.AccountNumber + ' ' + 'FROM ' + '**** ' + Fromb.AccountNumber + ' - ' + fromba.Name AS Description
   ,7.1 TypeId
   ,SUM(ISNULL(PF.Usd, 0)) AS Debit
   ,0 AS Credit
   ,SUM(ISNULL(PF.Usd, 0)) AS BalanceDetail
  FROM PaymentBanksToBanks PF
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PF.FromBankAccountId
  INNER JOIN BankAccounts Tob
    ON Tob.BankAccountId = PF.ToBankAccountId
  INNER JOIN Bank fromba
    ON Fromb.BankId = fromba.BankId
  --                             INNER JOIN Bank Toba ON Fromb.BankId = Toba.BankId
  WHERE (
  -- PF.FromBankAccountId = @BankAccountId OR 
  PF.ToBankAccountId = @BankAccountId
  OR @BankAccountId IS NULL)
  AND (CAST(PF.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PF.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PF.FromBankAccountId
          ,PF.PaymentBanksToBankId
          ,Fromb.AccountNumber
          ,Tob.AccountNumber
          ,CAST(PF.Date AS DATE)
          ,fromba.Name



INSERT INTO @Result
  SELECT
    8
   ,PF.FromBankAccountId
   , -- FROMBANK TRANSFER
    PF.PaymentBanksToBankId AS PaymentBanksToBanks
   ,CAST(PF.Date AS DATE) AS DATE
   ,'TRANSFER' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,'CREDIT' Type
   ,'FROM ' + '**** ' + Fromb.AccountNumber + ' ' + 'TO ' + '**** ' + Tob.AccountNumber + ' - ' + Toba.Name AS Description
   ,7.2 TypeId
   ,0 AS Debit
   ,SUM(ISNULL(PF.Usd, 0)) AS Credit
   ,-SUM(ISNULL(PF.Usd, 0)) AS BalanceDetail
  FROM PaymentBanksToBanks PF
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PF.FromBankAccountId
  INNER JOIN BankAccounts Tob
    ON Tob.BankAccountId = PF.ToBankAccountId
  --                             INNER JOIN Bank fromba ON Fromb.BankId = fromba.BankId
  INNER JOIN Bank Toba
    ON Tob.BankId = Toba.BankId
  WHERE (PF.FromBankAccountId = @BankAccountId
  -- OR PF.ToBankAccountId = @BankAccountId
  OR @BankAccountId IS NULL)
  AND (CAST(PF.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PF.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PF.FromBankAccountId
          ,PF.PaymentBanksToBankId
          ,Fromb.AccountNumber
          ,Tob.AccountNumber
          ,CAST(PF.Date AS DATE)
          ,Toba.Name


INSERT INTO @Result

  SELECT
    9
   ,P.BankAccountId
   , --DEPOSIT O PAYMENT BANK
    0 AS PaymentBanksToBanks
   ,CAST(P.Date AS DATE) AS DATE
   ,'DEPOSIT' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,CASE
      WHEN CAST(P.IsDebitCredit AS BIT) = CAST(1 AS BIT) THEN 'DEPOSIT FROM ' + a.Code + ' - ' + a.Name
      ELSE 'DEPOSIT - ' + (SELECT TOP 1
            CAST(pb.Note AS VARCHAR(35))
          FROM PaymentBankNotes pb
          WHERE pb.PaymentBankId = P.PaymentBankId)
    END AS Description
   ,9 TypeId
   ,P.Usd AS Debit
   ,0 AS Credit
   ,(ISNULL(P.Usd, 0)) AS BalanceDetail
  --SUM(ISNULL(P.USD, 0)) AS BalanceDetail
  FROM [PaymentBanks] P
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = P.BankAccountId
  INNER JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies a
    ON a.AgencyId = P.AgencyId
  WHERE (P.BankAccountId = @BankAccountId)
  AND (CAST(P.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(P.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)

INSERT INTO @Result

  SELECT
    10
   ,PT.BankAccountId
   , --PROPERTIES C BILLTAXES
    0 AS PaymentBanksToBanks
   ,CAST(PT.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,'CREDIT' Type
   ,'TAXES - ' + RIGHT(PR.PIN, 4) + ' ' + CAST(CAST(PT.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PT.ToDate AS DATE) AS VARCHAR(30)) AS Description
   ,14 TypeId
   ,0 Debit
   ,SUM(ISNULL(PT.Usd, 0)) Credit
   ,-SUM(ISNULL(PT.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillTaxes PT
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PT.BankAccountId
      AND PT.CardBankId IS NULL
      AND PT.CheckNumber IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PT.PropertiesId
  WHERE (PT.BankAccountId = @BankAccountId)
  AND (CAST(PT.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PT.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PT.BankAccountId
          ,PT.PropertiesBillTaxesId
          ,Fromb.AccountNumber
          ,PR.PIN
          ,CAST(PT.CreationDate AS DATE)
          ,CAST(PT.FromDate AS DATE)
          ,CAST(PT.ToDate AS DATE)
          ,CAST(PT.AchDate AS DATE)


INSERT INTO @Result

  SELECT
    11
   ,PT.BankAccountId
   , --PROPERTIES C BILLTAXES CHECKS
    0 AS PaymentBanksToBanks
   ,CAST(PT.CreationDate AS DATE) AS DATE
   ,'CHECK' PaymentType
   ,'**** ' + Fromb.AccountNumber + ' - ' + PT.CheckNumber AS Number
   ,'CREDIT' Type
   ,'TAXES - ' + RIGHT(PR.PIN, 4) + ' ' + CAST(CAST(PT.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PT.ToDate AS DATE) AS VARCHAR(30)) AS Description
   ,16 TypeId
   ,0 Debit
   ,SUM(ISNULL(PT.Usd, 0)) Credit
   ,-SUM(ISNULL(PT.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillTaxes PT
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PT.BankAccountId
      AND PT.CardBankId IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PT.PropertiesId
  WHERE (PT.CheckNumber IS NOT NULL)
  AND (PT.BankAccountId = @BankAccountId)
  AND (CAST(PT.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PT.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PT.BankAccountId
          ,Fromb.AccountNumber
          ,PR.PIN
          ,PT.CheckNumber
          ,CAST(PT.CreationDate AS DATE)
          ,CAST(PT.FromDate AS DATE)
          ,CAST(PT.ToDate AS DATE)


INSERT INTO @Result

  SELECT
    12
   ,PW.BankAccountId
   , --PROPERTIES WATER
    0 AS PaymentBanksToBanks
   ,CAST(PW.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,'CREDIT' Type
   ,'WATER - ' + RIGHT(PW.BillNumberSaved, 4) + ' ' + CAST(CAST(PW.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PW.ToDate AS DATE) AS VARCHAR(30)) AS Description
   ,17 TypeId
   ,0 Debit
   ,SUM(ISNULL(PW.Usd, 0)) Credit
   ,-SUM(ISNULL(PW.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillWater PW
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PW.BankAccountId
      AND PW.CardBankId IS NULL
      AND PW.CheckNumber IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PW.PropertiesId
  WHERE (PW.BankAccountId = @BankAccountId)
  AND (CAST(PW.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PW.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PW.BankAccountId
          ,PW.PropertiesBillWaterId
          ,Fromb.AccountNumber
          ,PW.BillNumberSaved
          ,CAST(PW.CreationDate AS DATE)
          ,CAST(PW.FromDate AS DATE)
          ,CAST(PW.ToDate AS DATE)
          ,CAST(PW.AchDate AS DATE)


INSERT INTO @Result
  SELECT
    13
   ,PW.BankAccountId
   , --PROPERTIES WATER CHECK
    0 AS PaymentBanksToBanks
   ,CAST(PW.CreationDate AS DATE) AS DATE
   ,'CHECK' PaymentType
   ,'**** ' + Fromb.AccountNumber + ' - ' + PW.CheckNumber AS Number
   ,'CREDIT' Type
   ,'WATER - ' + RIGHT(PW.BillNumberSaved, 4) + ' ' + CAST(CAST(PW.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PW.ToDate AS DATE) AS VARCHAR(30)) AS Description
   ,19 TypeId
   ,0 Debit
   ,SUM(ISNULL(PW.Usd, 0)) Credit
   ,-SUM(ISNULL(PW.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillWater PW
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PW.BankAccountId
      AND PW.CardBankId IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PW.PropertiesId
  WHERE (PW.CheckNumber IS NOT NULL)
  AND (PW.BankAccountId = @BankAccountId)
  AND (CAST(PW.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PW.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PW.BankAccountId
          ,Fromb.AccountNumber
          ,PW.CheckNumber
          ,PW.BillNumberSaved
          ,CAST(PW.CreationDate AS DATE)
          ,CAST(PW.FromDate AS DATE)
          ,CAST(PW.ToDate AS DATE)


INSERT INTO @Result

  SELECT
    14
   ,PIN.BankAccountId
   , --PROPERTIES INSURANCE
    0 AS PaymentBanksToBanks
   ,CAST(PIN.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,'CREDIT' Type
   ,'INSURANCE - ' + RIGHT(PIN.PolicyNumberSaved, 4) + ' ' + CAST(CAST(PIN.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PIN.ToDate AS DATE) AS VARCHAR(30)) AS Description
   ,20 TypeId
   ,0 Debit
   ,SUM(ISNULL(PIN.Usd, 0)) Credit
   ,-SUM(ISNULL(PIN.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillInsurance PIN
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PIN.BankAccountId
      AND PIN.CardBankId IS NULL
      AND PIN.CheckNumber IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PIN.PropertiesId
  WHERE (PIN.BankAccountId = @BankAccountId)
  AND (CAST(PIN.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PIN.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PIN.BankAccountId
          ,PIN.PropertiesBillInsuranceId
          ,Fromb.AccountNumber
          ,PIN.PolicyNumberSaved
          ,CAST(PIN.CreationDate AS DATE)
          ,CAST(PIN.FromDate AS DATE)
          ,CAST(PIN.ToDate AS DATE)
          ,CAST(PIN.AchDate AS DATE)

INSERT INTO @Result
  SELECT
    15
   ,PIN.BankAccountId
   , --PROPERTIES INSURANCE CHECK
    0 AS PaymentBanksToBanks
   ,CAST(PIN.CreationDate AS DATE) AS DATE
   ,'CHECK' PaymentType
   ,'**** ' + Fromb.AccountNumber + ' - ' + PIN.CheckNumber AS Number
   ,'CREDIT' Type
   ,'INSURANCE - ' + RIGHT(PIN.PolicyNumberSaved, 4) + ' ' + CAST(CAST(PIN.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PIN.ToDate AS DATE) AS VARCHAR(30)) AS Description
   ,22 TypeId
   ,0 Debit
   ,SUM(ISNULL(PIN.Usd, 0)) Credit
   ,-SUM(ISNULL(PIN.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillInsurance PIN
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PIN.BankAccountId
      AND PIN.CardBankId IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PIN.PropertiesId
  WHERE (PIN.CheckNumber IS NOT NULL)
  AND (PIN.BankAccountId = @BankAccountId)
  AND (CAST(PIN.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PIN.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PIN.BankAccountId
          ,Fromb.AccountNumber
          ,PIN.CheckNumber
          ,PIN.PolicyNumberSaved
          ,CAST(PIN.CreationDate AS DATE)
          ,CAST(PIN.FromDate AS DATE)
          ,CAST(PIN.ToDate AS DATE)

INSERT INTO @Result
  SELECT
    16
   ,Fromb.BankAccountId
   , --PROPERTIES LABOR
    0 AS PaymentBanksToBanks
   ,CAST(PL.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,
    -- '**** ' + Fromb.AccountNumber +  '-' +  C.CardNumber  AS Number, 
    'CREDIT' Type
   ,
    --                               'LABOR-' + RIGHT(PR.PIN, 4) + ' ' + CAST(CAST(PL.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PL.ToDate AS DATE) AS VARCHAR(30)) AS Description, 
    'LABOR - ' + PR.Name + ' ' + ISNULL(+'#' + a.Number, ' ') AS Description
   ,23 TypeId
   ,0 Debit
   ,SUM(ISNULL(PL.Usd, 0)) Credit
   ,-SUM(ISNULL(PL.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillLabor PL
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PL.BankAccountId
      AND PL.CardBankId IS NULL
      AND PL.CheckNumber IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PL.PropertiesId
  LEFT JOIN Apartments a
    ON PL.ApartmentId = a.ApartmentsId
  WHERE (Fromb.BankAccountId = @BankAccountId)
  AND (CAST(PL.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PL.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY Fromb.BankAccountId
          ,PL.PropertiesBillLaborId
          ,Fromb.AccountNumber
          ,PR.PIN
          ,CAST(PL.CreationDate AS DATE)
          ,CAST(PL.FromDate AS DATE)
          ,CAST(PL.ToDate AS DATE)
          ,CAST(PL.AchDate AS DATE)
          ,PR.Name
          ,a.Number

INSERT INTO @Result

  SELECT
    17
   ,PL.BankAccountId
   , --PROPERTIES LABOR  CHECK
    0 AS PaymentBanksToBanks
   ,CAST(PL.CreationDate AS DATE) AS DATE
   ,'CHECK' PaymentType
   ,'**** ' + Fromb.AccountNumber + ' - ' + PL.CheckNumber AS Number
   ,'CREDIT' Type
   ,
    --                               'LABOR-' + RIGHT(PR.PIN, 4) + ' ' + CAST(CAST(PL.FromDate AS DATE) AS VARCHAR(30)) + ' TO ' + CAST(CAST(PL.ToDate AS DATE) AS VARCHAR(30)) AS Description, 
    'LABOR - ' + PR.Name + ' ' + ISNULL(+'#' + a.Number, ' ') AS Description
   ,25 TypeId
   ,0 Debit
   ,SUM(ISNULL(PL.Usd, 0)) Credit
   ,-SUM(ISNULL(PL.Usd, 0)) AS BalanceDetail
  FROM PropertiesBillLabor PL
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PL.BankAccountId
      AND PL.CardBankId IS NULL
  INNER JOIN Properties PR
    ON PR.PropertiesId = PL.PropertiesId
  LEFT JOIN Apartments a
    ON PL.ApartmentId = a.ApartmentsId
  WHERE (PL.CheckNumber IS NOT NULL)
  AND (PL.BankAccountId = @BankAccountId)
  AND (CAST(PL.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PL.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PL.BankAccountId
          ,Fromb.AccountNumber
          ,PL.CheckNumber
          ,PR.PIN
          ,CAST(PL.CreationDate AS DATE)
          ,CAST(PL.FromDate AS DATE)
          ,CAST(PL.ToDate AS DATE)
          ,PR.Name
          ,a.Number



INSERT INTO @Result
  SELECT
    18
   ,PO.BankAccountId
   , --PROPERTIES OTHERS ACCOUNT
    0 AS PaymentBanksToBanks
   ,CAST(PO.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,
    -- '**** ' + Fromb.AccountNumber +  '-' +  C.CardNumber  AS Number, 
    (CASE
      WHEN PO.IsCredit = 1 THEN 'DEBIT' --'CREDIT' 
      ELSE 'CREDIT' --'DEBIT'
    END) Type
   ,p.Name + ' - OTHERS ' + '(' + PO.Description + ')' AS Description
   ,26 TypeId
   ,(CASE
      WHEN PO.IsCredit = 1 --PO.IsCredit = 0
      THEN (ISNULL(PO.Usd, 0))
      ELSE 0
    END) Debit
   ,(CASE
      WHEN PO.IsCredit = 0 -- PO.IsCredit = 1
      THEN (ISNULL(PO.Usd, 0))
      ELSE 0
    END) credit
   ,(CASE
      WHEN PO.IsCredit = 1 THEN (ISNULL(PO.Usd, 0))  -- -(ISNULL(PO.USD, 0))
      ELSE -(ISNULL(PO.Usd, 0)) --(ISNULL(PO.USD, 0))
    END) BalanceDetail
  FROM PropertiesBillOthers PO
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PO.BankAccountId
      AND PO.CardBankId IS NULL
      AND PO.CheckNumber IS NULL
  INNER JOIN Properties p
    ON PO.PropertiesId = p.PropertiesId
  WHERE (PO.BankAccountId = @BankAccountId)
  AND (CAST(PO.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PO.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
INSERT INTO @Result


  --                     
  SELECT
    19
   ,PO.BankAccountId
   , --PROPERTIES OTHERS CHECKS
    0 AS PaymentBanksToBanks
   ,CAST(PO.CreationDate AS DATE) AS DATE
   ,'CHECK' PaymentType
   ,
    --'**** ' + Fromb.AccountNumber AS Number,
    '**** ' + Fromb.AccountNumber + ' - ' + PO.CheckNumber AS Number
   ,(CASE
      WHEN PO.IsCredit = 0 THEN 'CREDIT'
      ELSE 'DEBIT'
    END) Type
   ,p.Name + ' - OTHERS ' + '(' + PO.Description + ')' AS Description
   ,28 TypeId
   ,(CASE
      WHEN PO.IsCredit = 1 THEN SUM(ISNULL(PO.Usd, 0))
      ELSE 0
    END) Debit
   ,(CASE
      WHEN PO.IsCredit = 0 THEN SUM(ISNULL(PO.Usd, 0))
      ELSE 0
    END) credit
   ,(CASE
      WHEN PO.IsCredit = 0 THEN -SUM(ISNULL(PO.Usd, 0))
      ELSE SUM(ISNULL(PO.Usd, 0))
    END) BalanceDetail


  FROM PropertiesBillOthers PO
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = PO.BankAccountId
      AND PO.CardBankId IS NULL
  INNER JOIN Properties p
    ON PO.PropertiesId = p.PropertiesId
  WHERE (PO.CheckNumber IS NOT NULL)
  AND (PO.BankAccountId = @BankAccountId)
  AND (CAST(PO.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(PO.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY PO.BankAccountId
          ,Fromb.AccountNumber
          ,PO.CheckNumber
          ,PO.IsCredit
          ,CAST(PO.CreationDate AS DATE)
          ,PO.Description
          ,p.Name


INSERT INTO @Result

  SELECT
    20
   ,CP.BankAccountId
   , -- C CARD PAYMENTS MID
    0 AS PaymentBanksToBanks
   ,CAST(CP.ToDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CP.IsCredit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END) Type
   ,
    --'MID*******' + ' ' + RIGHT(A.MID, 4) AS Description, 
    CASE
      WHEN A.Mid IS NOT NULL THEN REPLACE(A.Code + ' - ' + 'CARD PAYMENT' + ' - MID *** ' + RIGHT(CP.MidSaved, 4), CHAR(13) + CHAR(10), ' ')
      ELSE A.Code + ' - ' + 'MID***'
    END AS Description
   ,31 TypeId
   ,(CASE
      WHEN CP.IsCredit = 0 THEN 0
      ELSE SUM(ISNULL(CPS.Usd, 0))
    END) Debit
   ,(CASE
      WHEN CP.IsCredit = 1 THEN 0
      ELSE SUM(ISNULL(CPS.Usd, 0))
    END) Credit
   ,(CASE
      WHEN CP.IsCredit = 0 THEN -SUM(ISNULL(CPS.Usd, 0))
      ELSE SUM(ISNULL(CPS.Usd, 0))
    END) BalanceDetail
  FROM ConciliationCardPayments CP
  --INNER JOIN Agencies A ON A.AgencyId = CP.AgencyId
  INNER JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CP.BankAccountId
  INNER JOIN ConciliationCardPaymentsDetails CPS
    ON CPS.ConciliationCardPaymentId = CP.ConciliationCardPaymentId
  INNER JOIN Agencies A
    ON A.AgencyId = CP.AgencyId
  WHERE (CP.BankAccountId = @BankAccountId)
  AND (CAST(CP.ToDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CP.ToDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CP.BankAccountId
          ,CP.ConciliationCardPaymentId
          ,Fromb.AccountNumber
          ,A.Code
          ,CP.IsCredit
          ,CP.MidSaved
          ,A.Mid
          ,CAST(CP.CreationDate AS DATE)
          ,CAST(CP.ToDate AS DATE)


INSERT INTO @Result

  SELECT
    21
   ,dbo.BankAccounts.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(dbo.Daily.CreationDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + CAST((SELECT
        RIGHT(dbo.BankAccounts.AccountNumber, 4))
    AS VARCHAR(4)) AS Number
   ,'DEBIT' Type
   ,'MONEY DISTRIBUTION - ' + dbo.Users.Name + ' - ' + a.Code AS Description
   ,32 TypeId
   ,SUM(ISNULL(dbo.DailyDistribution.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(dbo.DailyDistribution.Usd, 0)) AS BalanceDetail
  FROM dbo.Daily
  INNER JOIN dbo.DailyDistribution
    ON dbo.Daily.DailyId = dbo.DailyDistribution.DailyId
  INNER JOIN dbo.Cashiers
  INNER JOIN dbo.Users
    ON dbo.Cashiers.UserId = dbo.Users.UserId
    ON dbo.Daily.CashierId = dbo.Cashiers.CashierId
  INNER JOIN dbo.BankAccounts
    ON dbo.DailyDistribution.BankAccountId = dbo.BankAccounts.BankAccountId
  INNER JOIN dbo.Bank
    ON dbo.BankAccounts.BankId = dbo.Bank.BankId
  INNER JOIN Agencies a
    ON Daily.AgencyId = a.AgencyId
  WHERE (dbo.BankAccounts.BankAccountId = @BankAccountId)
  AND (CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY dbo.BankAccounts.BankAccountId
          ,dbo.BankAccounts.AccountNumber
          ,dbo.Users.Name
          ,CAST(dbo.Daily.CreationDate AS DATE)
          ,a.Code

INSERT INTO @Result
  SELECT
    22
   ,CB.BankAccountId
   , -- C MONEY TRANSFER
    0 AS PaymentBanksToBanks
   ,CAST(CB.Date AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Fromb.AccountNumber AS Number
   ,(CASE
      WHEN CB.IsCredit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END) Type
   ,REPLACE(A.Code + ' - ' + P.Name, CHAR(13) + CHAR(10), ' ') Description
   ,
    --P.Name   AS Description, 
    33 TypeId
   ,(CASE
      WHEN CB.IsCredit = 0 THEN 0
      ELSE (ISNULL(CB.Usd, 0))
    END) Debit
   ,(CASE
      WHEN CB.IsCredit = 1 THEN 0
      ELSE (ISNULL(CB.Usd, 0))
    END) Credit
   ,(CASE
      WHEN CB.IsCredit = 0 THEN -(ISNULL(CB.Usd, 0))
      ELSE (ISNULL(CB.Usd, 0))
    END) BalanceDetail
  FROM ConciliationMoneyTransfers CB
  INNER JOIN Agencies A
    ON A.AgencyId = CB.AgencyId
  LEFT JOIN BankAccounts Fromb
    ON Fromb.BankAccountId = CB.BankAccountId
  LEFT JOIN Providers P
    ON CB.ProviderId = P.ProviderId
  WHERE (CB.BankAccountId = @BankAccountId)
  AND (CAST(CB.Date AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CB.Date AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)





INSERT INTO @Result
  SELECT
    23
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(CE.FromDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'CREDIT' Type
   ,A.Code + ' - COMMISSIONS-VEHICLE SERVICE ' AS Description
   ,34 TypeId
   ,0 Debit
   ,SUM(ISNULL(ED.Usd, 0)) Credit
   ,-SUM(ISNULL(ED.Usd, 0)) BalanceDetail
  FROM ConciliationELS CE
  LEFT JOIN ConciliationELSDetails ED
    ON CE.ConciliationELSId = ED.ConciliationELSId
  LEFT JOIN BankAccounts Ba
    ON Ba.BankAccountId = CE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  WHERE (CE.IsCommissionPayments = 1)
  AND (CE.BankAccountId = @BankAccountId)
  AND (CAST(CE.FromDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CE.FromDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CE.ConciliationELSId
          ,CE.BankAccountId
          ,Ba.AccountNumber
          ,CE.IsCredit
          ,CE.IsDebit
          ,A.Mid
          ,A.Code
          ,CAST(CE.FromDate AS DATE)



INSERT INTO @Result --Rent payments
  SELECT
    24
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
   , CASE WHEN CAST(CE.AchDate as DATE) IS NOT NULL THEN
   CAST(CE.AchDate AS DATE) ELSE
   CAST(CE.CreationDate AS DATE) END AS DATE
   ,'RENT PAYMENT' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,(SELECT TOP 1
        t.Name
      FROM Tenants t
      INNER JOIN TenantsXcontracts TX
        ON t.TenantId = TX.TenantId
      --                              INNER JOIN Contract c ON C.ContractId = TX.ContractId
      WHERE TX.Principal = 1
      AND c.ContractId = TX.ContractId)
    + ' - ' + p.Number AS Description
   ,35 TypeId
   ,SUM(ISNULL(CE.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(CE.Usd, 0)) BalanceDetail
  FROM RentPayments CE
  INNER JOIN Contract c
    ON c.ContractId = CE.ContractId
  INNER JOIN Apartments p
    ON p.ApartmentsId = c.ApartmentId
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = CE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  WHERE (CE.BankAccountId = @BankAccountId) AND ISNULL(CE.IsCredit, 0) = 1
  AND ((CE.AchDate IS NOT NULL AND 
  (CAST(CE.AchDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL)
  AND (CAST(CE.AchDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL))
 OR  (CE.AchDate IS NULL AND
  (CAST(CE.CreationDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL) AND 
  (CAST(CE.CreationDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL)) )
  GROUP BY CE.RentPaymentId
          ,CE.BankAccountId
          ,Ba.AccountNumber
          ,CAST(CE.CreationDate AS DATE)
		  ,CAST(CE.AchDate AS DATE)
          ,c.ContractId
          ,p.Number


INSERT INTO @Result --Rent payments debito
  SELECT
    24
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
   , CASE WHEN CAST(CE.AchDate as DATE) IS NOT NULL THEN
   CAST(CE.AchDate AS DATE) ELSE
   CAST(CE.CreationDate AS DATE) END AS DATE
   ,'RENT PAYMENT' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,(SELECT TOP 1
        t.Name
      FROM Tenants t
      INNER JOIN TenantsXcontracts TX
        ON t.TenantId = TX.TenantId
      --                              INNER JOIN Contract c ON C.ContractId = TX.ContractId
      WHERE TX.Principal = 1
      AND c.ContractId = TX.ContractId)
    + ' - ' + p.Number AS Description
   ,35 TypeId
   ,0 Debit
   ,SUM(ABS(ISNULL(CE.Usd, 0))) AS Credit
   ,-SUM(ISNULL(CE.Usd, 0)) BalanceDetail
  FROM RentPayments CE
  INNER JOIN Contract c
    ON c.ContractId = CE.ContractId
  INNER JOIN Apartments p
    ON p.ApartmentsId = c.ApartmentId
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = CE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  WHERE (CE.BankAccountId = @BankAccountId) AND ISNULL(CE.IsCredit, 0) = 0
  AND ((CE.AchDate IS NOT NULL AND 
  (CAST(CE.AchDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL)
  AND (CAST(CE.AchDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL))
 OR  (CE.AchDate IS NULL AND
  (CAST(CE.CreationDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL) AND 
  (CAST(CE.CreationDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL)) )
  GROUP BY CE.RentPaymentId
          ,CE.BankAccountId
          ,Ba.AccountNumber
          ,CAST(CE.CreationDate AS DATE)
		  ,CAST(CE.AchDate AS DATE)
          ,c.ContractId
          ,p.Number


INSERT INTO @Result --DEPOSIT payments
  SELECT
    25
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
    , CASE WHEN CAST(CE.AchDate as DATE) IS NOT NULL THEN
   CAST(CE.AchDate AS DATE) ELSE
   CAST(CE.CreationDate AS DATE) END AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,'DEPOSIT PAYMENT - ' + pr.Name + ' - ' + p.Number AS Description
   ,36 TypeId
   ,SUM(ISNULL(CE.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(CE.Usd, 0)) BalanceDetail
  FROM DepositFinancingPayments CE
  INNER JOIN Contract c
    ON c.ContractId = CE.ContractId
  INNER JOIN Apartments p
    ON p.ApartmentsId = c.ApartmentId
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = CE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  INNER JOIN Properties pr
    ON pr.PropertiesId = p.PropertiesId
  WHERE (CE.BankAccountId = @BankAccountId)
  AND ((CE.AchDate IS NOT NULL AND 
  (CAST(CE.AchDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL)
  AND (CAST(CE.AchDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL))
 OR  (CE.AchDate IS NULL AND
  (CAST(CE.CreationDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL) AND 
  (CAST(CE.CreationDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL)) )
  GROUP BY CE.DepositFinancingPaymentsId
          ,CE.BankAccountId
          ,Ba.AccountNumber
          ,CAST(CE.CreationDate AS DATE)
		  ,CAST(CE.AchDate AS DATE)
          ,c.ContractId
          ,p.Number
          ,pr.Name


INSERT INTO @Result	-- Provider commission payment account
  SELECT
    26
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(CE.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,A.Code + ' - COMMISSION ' + p.Name + ' (' + [dbo].[fn_GetMonthByNum](CE.Month) + '  ' + CAST(CE.Year AS VARCHAR(4)) + ')' AS Description
   ,36 TypeId
   ,SUM(ISNULL(CE.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(CE.Usd, 0)) BalanceDetail
  FROM ProviderCommissionPayments CE
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = CE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  INNER JOIN Providers p
    ON p.ProviderId = CE.ProviderId
  WHERE (CE.BankAccountId = @BankAccountId)
  AND CE.IsForex = CAST(0 AS BIT)
  AND (CAST(CE.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CE.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CE.ProviderCommissionPaymentId
          ,CE.BankAccountId
          ,Ba.AccountNumber
          ,CAST(CE.CreationDate AS DATE)
          ,p.Name
          ,A.Code
          ,CE.Month
          ,CE.Year
          ,CAST(CE.AchDate AS DATE)

INSERT INTO @Result	-- Provider other commission payment account
  SELECT
    27
   ,ocE.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(ocE.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
    --       ,A.Code + ' - COMMISSION '  + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4))  AS Description
   ,A.Code + ' - COMMISSION ' + p.Name + ' (' + [dbo].[fn_GetMonthByNum](CE.Month) + '  ' +
    CAST(CE.Year AS VARCHAR(4)) + ')' AS Description
   ,37 TypeId
   ,SUM(ISNULL(ocE.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(ocE.Usd, 0)) BalanceDetail
  FROM OtherCommissions ocE
  INNER JOIN ProviderCommissionPayments CE
    ON ocE.ProviderCommissionPaymentId = CE.ProviderCommissionPaymentId
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = ocE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  INNER JOIN Providers p
    ON p.ProviderId = CE.ProviderId
  WHERE (ocE.BankAccountId = @BankAccountId)
  AND (CAST(ocE.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(ocE.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CE.ProviderCommissionPaymentId
          ,ocE.BankAccountId
          ,Ba.AccountNumber
          ,CAST(CE.CreationDate AS DATE)
          ,p.Name
          ,A.Code
          ,CE.Month
          ,CE.Year
          ,CAST(ocE.AchDate AS DATE)

INSERT INTO @Result	-- Provider commission payment account forex
  SELECT
    28
   ,CE.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(CE.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,A.Code + ' - COMMISSION ' + p.Name + ' (' + [dbo].[fn_GetMonthByNum](CE.Month) + '  ' +
    CAST(CE.Year AS VARCHAR(4)) + ')' + ' ' + 'FOREX' AS Description
   ,36 TypeId
   ,SUM(ISNULL(CE.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(CE.Usd, 0)) BalanceDetail
  FROM ProviderCommissionPayments CE
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = CE.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = CE.AgencyId
  INNER JOIN Providers p
    ON p.ProviderId = CE.ProviderId
  WHERE (CE.BankAccountId = @BankAccountId)
  AND CE.IsForex = CAST(1 AS BIT)
  AND (CAST(CE.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(CE.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY CE.ProviderCommissionPaymentId
          ,CE.BankAccountId
          ,Ba.AccountNumber
          ,CAST(CE.CreationDate AS DATE)
          ,p.Name
          ,A.Code
          ,CE.Month
          ,CE.Year
          ,CAST(CE.AchDate AS DATE)


INSERT INTO @Result	-- Returned checks Lawyer fee
  SELECT
    29
   ,l.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CASE
      WHEN l.AchDate IS NOT NULL THEN CAST(l.AchDate AS DATE)
      ELSE CAST(l.CreationDate AS DATE)
    END AS DATE
   ,CASE
      WHEN l.AchDate IS NOT NULL THEN 'ACH'
      ELSE 'CHECK'
    END AS PaymentType
   ,'**** ' + ba.AccountNumber AS Number
   ,'LAWYER FEE' Type
   ,uc.Name + ' - ' +
    CASE
      WHEN l.AchDate IS NOT NULL THEN 'ACH'
      ELSE 'CHECK #' + l.CheckNumber
    END AS Description
   ,37 TypeId
   ,0 Debit
   ,SUM(ISNULL(l.Usd, 0)) Credit
   ,-SUM(ISNULL(l.Usd, 0)) BalanceDetail
  FROM [dbo].[LawyerPayments] l
  INNER JOIN dbo.ReturnedCheck r
    ON r.ReturnedCheckId = l.ReturnedCheckId
  INNER JOIN dbo.Clientes c
    ON c.ClienteId = r.ClientId
  INNER JOIN dbo.Users uc
    ON uc.UserId = c.UsuarioId
  LEFT JOIN BankAccounts ba
    ON ba.BankAccountId = l.BankAccountId
  WHERE (l.BankAccountId = @BankAccountId)
  AND (l.CheckNumber IS NOT NULL
  OR l.AchDate IS NOT NULL)
  AND ((l.AchDate IS NOT NULL
  AND ((CAST(l.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(l.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)))
  OR (l.CheckNumber IS NOT NULL
  AND ((CAST(l.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(l.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL))))
  GROUP BY l.LawyerPaymentId
          ,l.BankAccountId
          ,ba.AccountNumber
          ,l.CreationDate
          ,l.AchDate
          ,uc.Name
          ,l.CheckNumber


INSERT INTO @Result	-- Returned checks Court fee
  SELECT
    29
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CASE
      WHEN c.AchDate IS NOT NULL THEN CAST(c.AchDate AS DATE)
      ELSE CAST(c.CreationDate AS DATE)
    END AS DATE
   ,CASE
      WHEN c.AchDate IS NOT NULL THEN 'ACH'
      ELSE 'CHECK'
    END AS PaymentType
   ,'**** ' + ba.AccountNumber AS Number
   ,'COURT FEE' Type
   ,uc.Name + ' - ' +
    CASE
      WHEN c.AchDate IS NOT NULL THEN 'ACH ' + CONVERT(VARCHAR, c.AchDate, 1)
      ELSE 'CHECK #' + c.CheckNumber
    END AS Description
   ,37 TypeId
   ,0 Debit
   ,SUM(ISNULL(c.Usd, 0)) Credit
   ,-SUM(ISNULL(c.Usd, 0)) BalanceDetail
  FROM [dbo].[CourtPayment] c
  INNER JOIN dbo.ReturnedCheck r
    ON r.ReturnedCheckId = c.ReturnedCheckId
  INNER JOIN dbo.Clientes cl
    ON cl.ClienteId = r.ClientId
  INNER JOIN dbo.Users uc
    ON uc.UserId = cl.UsuarioId
  LEFT JOIN BankAccounts ba
    ON ba.BankAccountId = c.BankAccountId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (c.CheckNumber IS NOT NULL
  OR c.AchDate IS NOT NULL)
  AND (((c.AchDate IS NOT NULL
  AND ((CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL))))
  OR (c.CheckNumber IS NOT NULL
  AND ((CAST(c.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL))))
  GROUP BY c.CourtPaymentId
          ,c.BankAccountId
          ,ba.AccountNumber
          ,c.CreationDate
          ,c.AchDate
          ,uc.Name
          ,c.CheckNumber


INSERT INTO @Result --Returned payments
  SELECT
    30
   ,rp.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(rp.AchDate AS DATE) AS DATE
   ,'ACH' PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'DEBIT' Type
   ,A.Code + ' - RETURNED CHECK PAYMENT ' + ' ' + ' # ' + rc.CheckNumber AS Description
   ,38 TypeId
   ,SUM(ISNULL(rp.Usd, 0)) Debit
   ,0 Credit
   ,SUM(ISNULL(rp.Usd, 0)) BalanceDetail
  FROM ReturnPayments rp

  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = rp.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  LEFT JOIN Agencies A
    ON A.AgencyId = rp.AgencyId
  INNER JOIN dbo.ReturnPaymentMode rpm
    ON rpm.ReturnPaymentModeId = rp.ReturnPaymentModeId
  INNER JOIN ReturnedCheck rc
    ON rp.ReturnedCheckId = rc.ReturnedCheckId
  WHERE (rp.BankAccountId = @BankAccountId)
  AND rpm.Code = 'C04'
  AND (CAST(rp.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(rp.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  GROUP BY rp.BankAccountId
          ,Ba.AccountNumber
          ,CAST(rp.AchDate AS DATE)
          ,A.Code
          ,rc.CheckNumber

INSERT INTO @Result --DEPOSIT refund payments
  SELECT
    31
   ,c.DepositRefundBankAccountId
   ,0 AS PaymentBanksToBanks
    , CASE WHEN CAST(c.AchDate as DATE) IS NOT NULL THEN
   CAST(c.AchDate AS DATE) ELSE
   CAST(c.RefundDate AS DATE) END AS DATE
   ,CASE
      WHEN c.DepositRefundCheckNumber IS NOT NULL THEN 'CHECK'
      ELSE 'ACH'
    END AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'CREDIT' Type
   ,'DEPOSIT REFUND - ' + pr.Name + ' - ' + a.Number AS Description
   ,39 TypeId
   ,0 Debit
   ,SUM(ISNULL(c.RefundUsd, 0)) Credit
   ,-SUM(ISNULL(c.RefundUsd, 0)) BalanceDetail
  FROM Contract c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.DepositRefundBankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN dbo.Apartments a
    ON c.ApartmentId = a.ApartmentsId
  INNER JOIN dbo.Properties pr
    ON pr.PropertiesId = a.PropertiesId
  WHERE (c.DepositRefundBankAccountId = @BankAccountId)
  AND ((c.AchDate IS NOT NULL AND 
  (CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL))
 OR  (c.AchDate IS NULL AND
  (CAST(c.CreationDate AS DATE) >= CAST(@FromDate AS DATE) OR @FromDate IS NULL) AND 
  (CAST(c.CreationDate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL)) )
  GROUP BY c.DepositRefundBankAccountId
          ,Ba.AccountNumber
          ,CAST(c.RefundDate AS DATE)
		  ,CAST(c.AchDate AS DATE)
          ,c.ContractId
          ,a.Number
          ,pr.Name
          ,c.DepositRefundCheckNumber


INSERT INTO @Result --Insurance new policy adjustment
  SELECT
    32
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(AchDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,CASE
      WHEN c.TypeId <> 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END AS [Type]
   ,a.Code + ' - NEW POLICY - #' + p.PolicyNumber + ' - ' + ic.Name +
    CASE
      WHEN c.TypeId = 3 THEN ' - COMMISSION'
      ELSE ''
    END AS Description
   ,40 TypeId
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))--1 = DEBIT, 2 = CREDIT
      ELSE 0
    END Debit
   ,CASE
      WHEN c.TypeId = 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Credit
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE SUM(ISNULL(c.Usd, 0)) * -1
    END BalanceDetail
  FROM dbo.InsuranceAchPayment c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN dbo.InsurancePolicy p
    ON p.InsurancePolicyId = c.InsurancePolicyId
  INNER JOIN dbo.InsurancePaymentType t
    ON t.InsurancePaymentTypeId = p.InsurancePaymentTypeId

  INNER JOIN Agencies a
    ON p.CreatedInAgencyId = a.AgencyId
  INNER JOIN InsuranceCompanies ic
    ON p.InsuranceCompaniesId = ic.InsuranceCompaniesId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'
  AND c.TypeId <> 3 -- 6424
  GROUP BY c.BankAccountId
          ,Ba.AccountNumber
          ,a.Code
          ,ic.Name
          ,CAST(c.AchDate AS DATE)
          ,p.PolicyNumber
          ,c.InsuranceAchPaymentId
          ,TypeId

INSERT INTO @Result --Insurance monthly payment adjustment
  SELECT
    33
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(AchDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,CASE
      WHEN c.TypeId <> 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END AS [Type]
   ,a.Code + ' - ' + ict.Description + ' - #' + ii.PolicyNumber + ' - ' + ic.Name +
    CASE
      WHEN c.TypeId = 3 THEN ' - COMMISSION'
      ELSE ''
    END AS Description
   ,41 TypeId
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Debit
   ,CASE
      WHEN c.TypeId = 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Credit
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE SUM(ISNULL(c.Usd, 0)) * -1
    END BalanceDetail
  FROM dbo.InsuranceAchPayment c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN dbo.InsuranceMonthlyPayment p
    ON p.InsuranceMonthlyPaymentId = c.InsuranceMonthlyPaymentId
  INNER JOIN dbo.InsurancePolicy ii
    ON ii.InsurancePolicyId = p.InsurancePolicyId
  INNER JOIN dbo.InsurancePaymentType t
    ON t.InsurancePaymentTypeId = p.InsurancePaymentTypeId

  INNER JOIN InsuranceCompanies ic
    ON ii.InsuranceCompaniesId = ic.InsuranceCompaniesId
  INNER JOIN Agencies a
    ON p.CreatedInAgencyId = a.AgencyId
  INNER JOIN InsuranceCommissionType ict
    ON p.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'
  AND ict.Code = 'C04'
  AND c.TypeId <> 3 -- 6424
  GROUP BY c.BankAccountId
          ,Ba.AccountNumber
          ,a.Code
          ,ict.Description
          ,ic.Name
          ,CAST(c.AchDate AS DATE)
          ,ii.PolicyNumber
          ,c.InsuranceAchPaymentId
          ,TypeId



INSERT INTO @Result --Insurance endorsement adjustment
  SELECT
    33
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(AchDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,CASE
      WHEN c.TypeId <> 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END AS [Type]
   ,a.Code + ' - ' + ict.Description + ' - #' + ii.PolicyNumber + ' - ' + ic.Name +
    CASE
      WHEN c.TypeId = 3 THEN ' - COMMISSION'
      ELSE ''
    END AS Description
   ,41 TypeId
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Debit
   ,CASE
      WHEN c.TypeId = 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Credit
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE SUM(ISNULL(c.Usd, 0)) * -1
    END BalanceDetail
  FROM dbo.InsuranceAchPayment c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN dbo.InsuranceMonthlyPayment p
    ON p.InsuranceMonthlyPaymentId = c.InsuranceMonthlyPaymentId
  INNER JOIN dbo.InsurancePolicy ii
    ON ii.InsurancePolicyId = p.InsurancePolicyId
  INNER JOIN dbo.InsurancePaymentType t
    ON t.InsurancePaymentTypeId = p.InsurancePaymentTypeId

  INNER JOIN InsuranceCompanies ic
    ON ii.InsuranceCompaniesId = ic.InsuranceCompaniesId
  INNER JOIN Agencies a
    ON p.CreatedInAgencyId = a.AgencyId
  INNER JOIN InsuranceCommissionType ict
    ON p.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'
  AND ict.Code = 'C03'
  AND c.TypeId <> 3 -- 6424
  GROUP BY c.BankAccountId
          ,Ba.AccountNumber
          ,a.Code
          ,ict.Description
          ,ic.Name
          ,CAST(c.AchDate AS DATE)
          ,ii.PolicyNumber
          ,c.InsuranceAchPaymentId
          ,TypeId



INSERT INTO @Result --Insurance policyRenewal adjustment
  SELECT
    33
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(AchDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,CASE
      WHEN c.TypeId <> 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END AS [Type]
   ,a.Code + ' - ' + ict.Description + ' - #' + ii.PolicyNumber + ' - ' + ic.Name +
    CASE
      WHEN c.TypeId = 3 THEN ' - COMMISSION'
      ELSE ''
    END AS Description
   ,41 TypeId
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Debit
   ,CASE
      WHEN c.TypeId = 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Credit
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE SUM(ISNULL(c.Usd, 0)) * -1
    END BalanceDetail
  FROM dbo.InsuranceAchPayment c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN dbo.InsuranceMonthlyPayment p
    ON p.InsuranceMonthlyPaymentId = c.InsuranceMonthlyPaymentId
  INNER JOIN dbo.InsurancePolicy ii
    ON ii.InsurancePolicyId = p.InsurancePolicyId
  INNER JOIN dbo.InsurancePaymentType t
    ON t.InsurancePaymentTypeId = p.InsurancePaymentTypeId

  INNER JOIN InsuranceCompanies ic
    ON ii.InsuranceCompaniesId = ic.InsuranceCompaniesId
  INNER JOIN Agencies a
    ON p.CreatedInAgencyId = a.AgencyId
  INNER JOIN InsuranceCommissionType ict
    ON p.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'
  AND ict.Code = 'C02'
  AND c.TypeId <> 3 -- 6424
  GROUP BY c.BankAccountId
          ,Ba.AccountNumber
          ,a.Code
          ,ict.Description
          ,ic.Name
          ,CAST(c.AchDate AS DATE)
          ,ii.PolicyNumber
          ,c.InsuranceAchPaymentId
          ,TypeId

INSERT INTO @Result --Insurance registration adjustment
  SELECT
    34
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(AchDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,CASE
      WHEN c.TypeId <> 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END AS [Type]
   ,a.Code + ' - REG. REL. (S.O.S) - ' + r.ClientName +
    CASE
      WHEN c.TypeId = 3 THEN ' - COMMISSION'
      ELSE ''
    END AS Description
   ,42 TypeId
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Debit
   ,CASE
      WHEN c.TypeId = 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE 0
    END Credit
   ,CASE
      WHEN c.TypeId <> 1 THEN SUM(ISNULL(c.Usd, 0))
      ELSE SUM(ISNULL(c.Usd, 0)) * -1
    END BalanceDetail
  FROM dbo.InsuranceAchPayment c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN dbo.InsuranceRegistration r
    ON r.InsuranceRegistrationId = c.InsuranceRegistrationId
  INNER JOIN dbo.InsurancePaymentType t
    ON t.InsurancePaymentTypeId = r.InsurancePaymentTypeId
  INNER JOIN Agencies a
    ON r.CreatedInAgencyId = a.AgencyId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.AchDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.AchDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'
  AND c.TypeId <> 3 -- 6424
  GROUP BY c.InsuranceAchPaymentId
          ,c.BankAccountId
          ,Ba.AccountNumber
          ,A.Code
          ,CAST(c.AchDate AS DATE)
          ,r.ClientName
          ,TypeId

INSERT INTO @Result --Tickets ACH payments
  SELECT
    35
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(c.UpdateToPendingDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'CREDIT' Type
   ,a.Code + ' - TRAFFIC TICKET - ' + c.TicketNumber AS Description
   ,43 TypeId
   ,0 Debit
   ,ISNULL(c.Usd, 0) Credit
   ,ISNULL(c.Usd, 0) * -1 BalanceDetail
  FROM dbo.Tickets c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN Agencies a
    ON c.AgencyId = a.AgencyId
  INNER JOIN dbo.TicketPaymentTypes t
    ON t.TicketPaymentTypeId = c.TicketPaymentTypeId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'


INSERT INTO @Result --Tickets ACH payments Transaction fee
  SELECT
    36
   ,c.BankAccountId
   ,0 AS PaymentBanksToBanks
   ,CAST(c.UpdateToPendingDate AS DATE) AS DATE
   ,'ACH' AS PaymentType
   ,'**** ' + Ba.AccountNumber AS Number
   ,'CREDIT' Type
   ,a.Code + ' - TRAFFIC TICKET - ' + c.TicketNumber + ' - FEE' AS Description
   ,44 TypeId
   ,0 Debit
   ,ISNULL(c.TransactionFee, 0) Credit
   ,ISNULL(c.TransactionFee, 0) * -1 BalanceDetail
  FROM dbo.Tickets c
  INNER JOIN BankAccounts Ba
    ON Ba.BankAccountId = c.BankAccountId
  LEFT JOIN Bank B
    ON Ba.BankId = B.BankId
  INNER JOIN Agencies a
    ON c.AgencyId = a.AgencyId
  INNER JOIN dbo.TicketPaymentTypes t
    ON t.TicketPaymentTypeId = c.TicketPaymentTypeId
  WHERE (c.BankAccountId = @BankAccountId)
  AND (CAST(c.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND t.Code = 'C04'
  AND (c.TransactionFee IS NOT NULL
  AND c.TransactionFee > 0)


RETURN;
END;



GO