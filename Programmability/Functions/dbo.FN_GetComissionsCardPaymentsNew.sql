SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------
--Last update by JT/29-06-2024 TASK 5923 POINT 5
---------------------------------------------------------------------

-- 2024-11-28 DJ/6227:  Agregar pagos con tarjeta a los reportes de CARD PAYMENT

-- 2024-11-28 JT/6227:  Error con las card fee en el reporte de comisiones(En las TAB CARD PAYMENT y CARD PAYMENTS DETAIL esta arrojando el valor correcto, pero en la TAB CARD PAYMENTS FEE COMMISSIONS)
-- 20204-02-20 JT/5939: Para los insurance se agrupa la información por el Nuevo campo TransactionGuid


CREATE FUNCTION [dbo].[FN_GetComissionsCardPaymentsNew] (@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Month INT = NULL,
@Year INT = NULL,
@AgencyId INT,
@FromCommissions INT)
RETURNS @result TABLE (
  RowNumberDetail INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,Transactions INT
 ,TypeId INT
 ,Usd DECIMAL(18, 2)
 ,FeeService DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS
BEGIN


  DECLARE @YearFrom AS INT
         ,@YearTo AS INT
         ,@MonthFrom AS INT
         ,@MonthTo AS INT
         ,@ProviderId AS INT

  SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
  SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
  SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
  SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
  SET @ProviderId = (SELECT TOP 1
      ProviderId
    FROM Providers
    INNER JOIN ProviderTypes
      ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
    WHERE ProviderTypes.Code = 'C25');


  DECLARE @TableReturn TABLE (
    RowNumberDetail INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,Transactions INT
   ,TypeId INT
   ,Usd DECIMAL(18, 2)
   ,FeeService DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
  );
  INSERT INTO @TableReturn (RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  Transactions,
  TypeId,
  Usd,
  FeeService,
  Credit,
  BalanceDetail)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY Query.TypeId ASC,
        CAST(Query.Date AS Date) ASC) RowNumberDetail
       ,AgencyId
       ,Query.Date
       ,Query.Description
       ,Query.Type
       ,SUM(Query.Transactions) Transactions
       ,Query.TypeId
       ,SUM(Query.Usd) Usd
       ,SUM(Query.FeeService) FeeService
       ,SUM(Query.Credit) Credit
       ,SUM(Query.BalanceDetail) BalanceDetail
      FROM (
        --DepositFinancingPayments
        SELECT
          DP.AgencyId
         ,CAST(DP.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(DP.Usd, 0)) + SUM(ISNULL(DP.CardPaymentFee, 0)) AS Usd
         ,SUM(ISNULL(DP.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(DP.CardPaymentFee, 0)) AS BalanceDetail
        FROM DepositFinancingPayments DP
        INNER JOIN Agencies A
          ON A.AgencyId = DP.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND DP.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY DP.AgencyId
                ,CAST(DP.CreationDate AS DATE)
        UNION ALL--RentPayments
        SELECT
          RN.AgencyId
         ,CAST(RN.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(RN.Usd, 0)) + SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS Usd
         ,SUM(ISNULL(RN.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS BalanceDetail
          SUM(ISNULL(RN.CardPaymentFee, 0)) AS BalanceDetail
        FROM RentPayments RN
        INNER JOIN Agencies A
          ON A.AgencyId = RN.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND RN.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY RN.AgencyId
                ,CAST(RN.CreationDate AS DATE)
        UNION ALL--ProvisionalReceipts
        SELECT
          PR.AgencyId
         ,CAST(PR.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(PR.Total, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) + SUM(ISNULL(PR.OtherFees, 0)) AS Usd
         ,
          --SUM(ISNULL(PR.OtherFees, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) AS FeeService, 
          SUM(ISNULL(PR.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(PR.OtherFees, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) AS BalanceDetail
          SUM(ISNULL(PR.CardPaymentFee, 0)) AS BalanceDetail
        FROM ProvisionalReceipts PR
        INNER JOIN Agencies A
          ON A.AgencyId = PR.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND PR.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY PR.AgencyId
                ,CAST(PR.CreationDate AS DATE)
        UNION ALL --ReturnedCheck
        SELECT
          A.AgencyId
         ,CAST(P.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(P.Usd, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) AS Usd
         ,SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
        FROM ReturnedCheck RC
        INNER JOIN ReturnPayments P
          ON P.ReturnedCheckId = RC.ReturnedCheckId
        INNER JOIN Agencies A
          ON A.AgencyId = P.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND P.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, P.CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, P.CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY A.AgencyId
                ,CAST(P.CreationDate AS DATE)
        UNION ALL --CountryTaxes
        SELECT
          T.AgencyId
         ,CAST(T.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(T.Usd, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) + SUM(ISNULL(T.Fee1, 0)) AS Usd
         ,
          --SUM(ISNULL(T.Fee1, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) AS FeeService, 
          SUM(ISNULL(T.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(T.Fee1, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) AS BalanceDetail
          SUM(ISNULL(T.CardPaymentFee, 0)) AS BalanceDetail
        FROM CountryTaxes T
        INNER JOIN Agencies A
          ON A.AgencyId = T.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND T.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY T.AgencyId
                ,CAST(T.CreationDate AS DATE)
        UNION ALL --PromotionalCodes CityStickers
        SELECT
          C.AgencyId
         ,CAST(C.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(C.Usd, 0)) + SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS Usd
         ,SUM(ISNULL(C.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
          SUM(ISNULL(C.CardPaymentFee, 0)) AS BalanceDetail
        FROM dbo.PromotionalCodes AS PC
        INNER JOIN dbo.PromotionalCodesStatus AS PS
          ON PC.PromotionalCodeId = PS.PromotionalCodeId
        RIGHT OUTER JOIN dbo.CityStickers AS C
        INNER JOIN dbo.Agencies AS A
          ON A.AgencyId = C.AgencyId
          ON PS.CityStickerId = C.CityStickerId
        WHERE A.AgencyId = @AgencyId
        AND C.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, C.CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, C.CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        AND C.TitleParentId IS NULL --Only city stickers no child of titles. --Last update by JT/29-06-2024 TASK 5923 POINT 5

        GROUP BY C.AgencyId
                ,CAST(C.CreationDate AS DATE)
        UNION ALL --PromotionalCodes PlateStickers
        SELECT
          PL.AgencyId
         ,CAST(PL.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(PL.Usd, 0)) + SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS Usd
         ,
          --SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
          SUM(ISNULL(PL.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
          SUM(ISNULL(PL.CardPaymentFee, 0)) AS BalanceDetail
        FROM dbo.PromotionalCodes AS PC
        INNER JOIN dbo.PromotionalCodesStatus AS PS
          ON PC.PromotionalCodeId = PS.PromotionalCodeId
        RIGHT OUTER JOIN dbo.PlateStickers AS PL
        INNER JOIN dbo.Agencies AS A
          ON A.AgencyId = PL.AgencyId
          ON PS.PlateStickerId = PL.PlateStickerId
        WHERE A.AgencyId = @AgencyId
        AND PL.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, PL.CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, PL.CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(PL.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(PL.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY PL.AgencyId
                ,CAST(PL.CreationDate AS DATE)
        UNION ALL --Titles
        SELECT
          TS.AgencyId
         ,CAST(TS.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(TS.Usd, 0)) + SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0))
          + ISNULL((SELECT
              ISNULL(ISNULL(cs.Usd, 0) + ISNULL(cs.Fee1, 0), 0)
            FROM CityStickers cs
            WHERE cs.TitleParentId = TS.TitleId)
          , 0) --Last update by JT/29-06-2024 TASK 5923 POINT 5
          AS Usd
         ,
          --SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
          SUM(ISNULL(TS.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
          SUM(ISNULL(TS.CardPaymentFee, 0)) AS BalanceDetail
        FROM dbo.PromotionalCodes AS PC
        INNER JOIN dbo.PromotionalCodesStatus AS PS
          ON PC.PromotionalCodeId = PS.PromotionalCodeId
        RIGHT OUTER JOIN dbo.Titles AS TS
        INNER JOIN dbo.Agencies AS A
          ON A.AgencyId = TS.AgencyId
          ON PS.TitleId = TS.TitleId
        WHERE A.AgencyId = @AgencyId
        AND TS.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, TS.CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, TS.CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(TS.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(TS.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY TS.AgencyId
                ,CAST(TS.CreationDate AS DATE)
                ,TS.TitleId
        UNION ALL --Parkingtickets
        SELECT
          P.AgencyId
         ,CAST(P.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(P.Usd, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS Debit
         ,
          --SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS FeeService, 
          SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS BalanceDetail
          SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
        FROM ParkingTickets P
        INNER JOIN Agencies A
          ON A.AgencyId = P.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND P.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY P.AgencyId
                ,CAST(P.CreationDate AS DATE)
        UNION ALL --Tickets
        SELECT
          PK.AgencyId
         ,CAST(PK.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,1 AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(PK.Usd, 0)) +  MAX(ISNULL(PK.CardPaymentFee, 0))  + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS Usd
         ,
          --SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS FeeService, 
           MAX(ISNULL(PK.CardPaymentFee, 0))  AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS BalanceDetail
           MAX(ISNULL(PK.CardPaymentFee, 0))  AS BalanceDetail
        FROM Tickets PK
        INNER JOIN Agencies A
          ON A.AgencyId = PK.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND PK.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY PK.AgencyId
                ,CAST(PK.CreationDate AS DATE)
                ,PK.TransactionGuid
        UNION ALL --titleInquiry
        SELECT
          TI.AgencyId
         ,CAST(TI.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(TI.Usd, 0)) + SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS Usd
         ,
          --SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS FeeService, 
          SUM(ISNULL(TI.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS BalanceDetail
          SUM(ISNULL(TI.CardPaymentFee, 0)) AS BalanceDetail
        FROM TitleInquiry TI
        INNER JOIN Agencies A
          ON A.AgencyId = TI.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND TI.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY TI.AgencyId
                ,CAST(TI.CreationDate AS DATE)
        UNION ALL --TRP
        SELECT
          TR.AgencyId
         ,CAST(TR.CreatedOn AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(TR.Usd, 0)) + SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS Usd
         ,
          --SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS FeeService, 
          SUM(ISNULL(TR.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,
          --SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS BalanceDetail
          SUM(ISNULL(TR.CardPaymentFee, 0)) AS BalanceDetail
        FROM TRP TR
        INNER JOIN Agencies A
          ON A.AgencyId = TR.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND TR.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreatedOn) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreatedOn) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY TR.AgencyId
                ,CAST(TR.CreatedOn AS DATE)
        UNION ALL --OtherPayments
        SELECT
          OP.AgencyId
         ,CAST(OP.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,
          --'OtherPayment' Type, 
          COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(OP.Usd, 0)) + SUM(ISNULL(OP.CardPaymentFee, 0)) AS Usd
         ,SUM(ISNULL(OP.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(OP.CardPaymentFee, 0)) AS BalanceDetail
        FROM OtherPayments OP
        INNER JOIN Agencies A
          ON A.AgencyId = OP.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND OP.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY OP.AgencyId
                ,CAST(OP.CreationDate AS DATE)
        UNION ALL --OthersDetails
        SELECT
          OD.AgencyId
         ,CAST(OD.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,
          --'OtherDetails' Type, 
          COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(OD.Usd, 0)) + SUM(ISNULL(OD.CardPaymentFee, 0)) AS Usd
         ,SUM(ISNULL(OD.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(OD.CardPaymentFee, 0)) AS BalanceDetail
        FROM OthersDetails OD
        INNER JOIN Agencies A
          ON A.AgencyId = OD.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND OD.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY OD.AgencyId
                ,CAST(OD.CreationDate AS DATE)
        UNION ALL --HeadphonesAndChargers
        SELECT
          HC.AgencyId
         ,CAST(HC.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,
          --'OtherDetails' Type, 
          COUNT(*) AS Transactions
         ,1 TypeId
         ,CAST(SUM(ISNULL(HC.HeadphonesUsd, 0)) + SUM(ISNULL(HC.ChargersUsd, 0)) + SUM(ISNULL(HC.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS Usd
         ,SUM(ISNULL(HC.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(HC.CardPaymentFee, 0)) AS BalanceDetail
        FROM HeadphonesAndChargers HC
        INNER JOIN Agencies A
          ON A.AgencyId = HC.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND HC.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY HC.AgencyId
                ,CAST(HC.CreationDate AS DATE)
        UNION ALL --Phone sales
        SELECT
          A.AgencyId
         ,CAST(p.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,
          --'OtherDetails' Type, 
          COUNT(*) AS Transactions
         ,1 TypeId
         ,CAST(SUM(ISNULL(p.SellingValue, 0)) + SUM(ISNULL(pp.Usd, 0)) + ((SUM(ISNULL(p.SellingValue, 0)) * SUM(ISNULL(p.Tax, 0))) / 100) + SUM(ISNULL(p.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS Usd
         ,SUM(ISNULL(p.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(p.CardPaymentFee, 0)) AS BalanceDetail
        FROM PhoneSales p
        INNER JOIN InventoryByAgency IA
          ON IA.InventoryByAgencyId = p.InventoryByAgencyId
        INNER JOIN Agencies A
          ON A.AgencyId = IA.AgencyId
        INNER JOIN Users u
          ON u.UserId = p.CreatedBy
        LEFT JOIN PhonePlans pp
          ON pp.PhonePlanId = p.PhonePlanId
        WHERE A.AgencyId = @AgencyId
        AND p.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY A.AgencyId
                ,CAST(p.CreationDate AS DATE)
        UNION ALL --TicketFeeServices
        SELECT
          fs.AgencyId
         ,CAST(fs.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,
          --'OtherDetails' Type, 
          COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(fs.Usd, 0)) + SUM(ISNULL(fs.CardPaymentFee, 0)) AS Usd
         ,SUM(ISNULL(fs.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(fs.CardPaymentFee, 0)) AS BalanceDetail
        FROM TicketFeeServices fs
        INNER JOIN Agencies A
          ON A.AgencyId = fs.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND fs.UsedCard = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY fs.AgencyId
                ,CAST(fs.CreationDate AS DATE)
        UNION ALL --SystemToolsBill
        SELECT
          s.AgencyId
         ,CAST(s.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(s.Total, 0)) AS Usd
         ,SUM(ISNULL(s.CardPaymentFee, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(s.CardPaymentFee, 0)) AS BalanceDetail
        FROM SystemToolsBill s
        INNER JOIN Agencies A
          ON A.AgencyId = s.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND s.CardPayment = 1
        AND (@FromCommissions = 1
        AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
        OR @FromCommissions = 0
        AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))
        GROUP BY s.AgencyId
                ,CAST(s.CreationDate AS DATE)
        UNION ALL -- CardPayments one
        SELECT
          fs.AgencyId
         ,CAST(fs.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,
          --'OtherDetails' Type, 
          SUM(fs.NumberPayments) AS Transactions
         ,1 TypeId
         ,SUM(ISNULL(fs.Usd, 0)) + SUM(ISNULL(fs.TotalPay, 0)) + SUM(ISNULL(fs.Fee, 0)) + SUM(ISNULL(fs.FeeUsd, 0)) AS Usd
         ,SUM(ISNULL(fs.Fee, 0)) + SUM(ISNULL(fs.FeeUsd, 0)) AS FeeService
         ,0 Credit
         ,SUM(ISNULL(fs.Fee, 0)) + SUM(ISNULL(fs.FeeUsd, 0)) AS BalanceDetail
        FROM CardPayments fs
        INNER JOIN Agencies A
          ON A.AgencyId = fs.AgencyId
          AND (@FromCommissions = 1
          AND (CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
          AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year)
          OR @FromCommissions = 0
          AND ((CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)))
        WHERE fs.AgencyId = @AgencyId
        GROUP BY fs.AgencyId
                ,CAST(fs.CreationDate AS DATE)


		UNION ALL -- INSURANCE
        SELECT
          qi.AgencyId,
          CAST(qi.CreationDate as DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'CARD PAYMENT FEE' Type
         ,COUNT(*) Transactions
         ,1 TypeId
         ,SUM(qi.Usd + qi.CardFee) Usd
         ,SUM(qi.CardFee) FeeService
         ,0 Credit
         ,SUM(qi.CardFee) BalanceDetail
        FROM [dbo].[FN_GenerateInsuranceCardPaymentReport] (@AgencyId, @FromDate, @ToDate,@Month, @Year,@FromCommissions) qi
		GROUP BY qi.AgencyId, CAST(qi.CreationDate as DATE)


        UNION ALL
        SELECT
          Agencies.AgencyId
         ,
          --,ProviderCommissionPayments.CreationDate DATE
          CASE
            WHEN @FromCommissions = 1 THEN ProviderCommissionPayments.CreationDate
            ELSE dbo.[fn_GetNextDayPeriod](Year, Month)
          END
          AS DATE
         ,'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description
         ,'COMMISSION' Type
         ,TotalTransactions Transactions
         ,2 TypeId
         ,0 Usd
         ,0 FeeService
         ,ISNULL(ProviderCommissionPayments.Usd, 0) Credit
         ,-ISNULL(ProviderCommissionPayments.Usd, 0) BalanceDetail
        FROM dbo.ProviderCommissionPayments
        INNER JOIN dbo.Providers
          ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
        INNER JOIN dbo.ProviderCommissionPaymentTypes
          ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
        INNER JOIN dbo.Agencies
          ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
        LEFT OUTER JOIN dbo.Bank
          ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
        INNER JOIN dbo.ProviderTypes
          ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId

        WHERE --@FromCommissions = 0--Comisiones del reporte card payment commissions 
        --task 5382 la consulta de comisiones se debe filtrar con base en la fecha del pago de la comisión y no del periodo como se estaba haciendo antes
        ProviderCommissionPayments.AgencyId = @AgencyId
        AND ProviderCommissionPayments.ProviderId = @ProviderId
        AND ((@FromCommissions = 0
        --Task 5382 El pago de esta comisión, independientemente de la fecha en que se pague, en el reporte de TRP, debe salir con la fecha del primer día del mes después al periodo pagado, como se explica en la siguiente imagen:
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)))

		
		) AS Query

      GROUP BY AgencyId
              ,Date
              ,Description
              ,Type
              ,TypeId) AS QueryFinal
    ORDER BY RowNumberDetail ASC;
  INSERT INTO @result (RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  Transactions,
  TypeId,
  Usd,
  FeeService,
  Credit,
  BalanceDetail,
  Balance)
    (
    SELECT
      *
     ,(SELECT
          SUM(t2.BalanceDetail)
        FROM @TableReturn t2
        WHERE t2.RowNumberDetail <= t1.RowNumberDetail)
      Balance
    FROM @TableReturn t1
    );
  RETURN;
END;
GO