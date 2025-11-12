SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------
--Last update by JT/29-06-2024 TASK 5923 POINT 5
---------------------------------------------------------------------

--LASTUPDATEDBY: JT TASK 5845
--LASTUPDATEDON:05-06-2024
--TASK 5845 Error with the filters date for other pyaments 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  FN_GenerateBalanceCardPayment				    															         
-- Descripcion: Función que consulta la lista de card payments en un periodo y con su respectivo balance inicial		    					         
-- Creado por: 	John Terry García Martínez																						 
-- Fecha: 																								 	
-- Modificado por: John Terry García Martínez																							 
-- Fecha edición : 2023-09-20																											 
-- Observación:  Consulta los card payments dentro de la función [FN_GenerateBalanceCardPayment] por  @AgencyId, @FromDate, @ToDate
-- Test: EXECUTE [dbo].FN_GenerateBalanceCardPayment @AgencyId = 1, @FromDate = NULL, @ToDate = NULL, @Date = GETDATE()
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)
-- 2024-11-28 DJ/6227:  Agregar pagos con tarjeta a los reportes de CARD PAYMENT
-- 2024-11-28 JF/6227:  se incluyo el ultimo union all de Insurance en QueryAnindado
-- 2024-12-07 JF /6227: error calculo de comision a pagar no estaba teniendo en cuenta el @Month y @Year se implementó en el condicional
-- 20204-02-20 JT/5939: Para los insurance se agrupa la información por el Nuevo campo TransactionGuid


CREATE FUNCTION [dbo].[FN_GenerateBalanceCardPayment] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
  RowNumberDetail INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,Transactions INT
 ,TypeId INT
 ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS


BEGIN

  DECLARE @TableReturn TABLE (
    RowNumberDetail INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,Transactions INT
   ,TypeId INT
   ,Debit DECIMAL(18, 2)
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
  Debit,
  Credit,
  BalanceDetail)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY Query.TypeId ASC,
        CAST(Query.Date AS Date) ASC) RowNumberDetail
       ,*
      FROM (SELECT
          ----QueryFinal.RowNumber, 
          AgencyId
         ,CAST(Date AS Date) AS Date
         ,Description
         ,Type
         ,SUM(ISNULL(Transactions, 0)) AS Transactions
         ,TypeId
         ,SUM(ISNULL(Debit, 0)) AS Debit
         ,SUM(ISNULL(Credit, 0)) AS Credit
         ,SUM(ISNULL(BalanceDetail, 0)) AS BalanceDetail
        FROM (
          --DepositFinancingPayments
          SELECT
            DP.AgencyId
           ,CAST(DP.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'deposit' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(DP.USD, 0)) + SUM(ISNULL(DP.CardPaymentFee, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(DP.USD, 0)) + SUM(ISNULL(DP.CardPaymentFee, 0)) AS BalanceDetail
          FROM DepositFinancingPayments DP
          INNER JOIN Agencies A
            ON A.AgencyId = DP.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND DP.CardPayment = 1
          AND (CAST(DP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(DP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY DP.AgencyId
                  ,CAST(DP.CreationDate AS DATE)
          UNION ALL--RentPayments
          SELECT
            RN.AgencyId
           ,CAST(RN.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'Rent' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(RN.USD, 0)) + SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(RN.USD, 0)) + SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS BalanceDetail
          FROM RentPayments RN
          INNER JOIN Agencies A
            ON A.AgencyId = RN.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND RN.CardPayment = 1
          AND (CAST(RN.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(RN.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY RN.AgencyId
                  ,CAST(RN.CreationDate AS DATE)
          --          UNION ALL
          --          SELECT
          --            F.AgencyId
          --           ,CAST(P.CreatedOn AS DATE) AS DATE
          --           ,'CLOSING DAILY' Description
          --           ,'CARD PAYMENT' Type
          --           ,
          --            -- 'financing' Type, 
          --            COUNT(*) AS Transactions
          --           ,1 TypeId
          --           ,SUM(ISNULL(P.Usd, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) AS Debit
          --           ,0 Credit
          --           ,SUM(ISNULL(P.Usd, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
          --          FROM Financing F
          --          INNER JOIN Agencies A
          --            ON A.AgencyId = F.AgencyId
          --          INNER JOIN Payments P
          --            ON P.FinancingId = F.FinancingId
          --          WHERE A.AgencyId = @AgencyId
          --          AND P.CardPayment = 1
          --          AND (CAST(P.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
          --          OR @FromDate IS NULL)
          --          AND (CAST(P.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
          --          OR @ToDate IS NULL)
          --          GROUP BY F.AgencyId
          --                  ,CAST(P.CreatedOn AS DATE)
          UNION ALL--ProvisionalReceipts
          SELECT
            PR.AgencyId
           ,CAST(PR.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'Provisional' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(PR.Total, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) + SUM(ISNULL(PR.OtherFees, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(PR.Total, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) + SUM(ISNULL(PR.OtherFees, 0)) AS BalanceDetail
          FROM ProvisionalReceipts PR
          INNER JOIN Agencies A
            ON A.AgencyId = PR.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND PR.CardPayment = 1
          AND (CAST(PR.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(PR.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY PR.AgencyId
                  ,CAST(PR.CreationDate AS DATE)
          UNION ALL--ReturnedCheck
          SELECT
            P.AgencyId
           ,CAST(P.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,
            --'returned' Type, 
            'CARD PAYMENT' Type
           ,COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(P.USD, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(P.USD, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
          FROM ReturnedCheck RC

          INNER JOIN ReturnPayments P
            ON P.ReturnedCheckId = RC.ReturnedCheckId
          INNER JOIN Agencies A
            ON A.AgencyId = P.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND P.CardPayment = 1
          AND (CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY P.AgencyId
                  ,CAST(P.CreationDate AS DATE)
          UNION ALL --CountryTaxes
          SELECT
            T.AgencyId
           ,CAST(T.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'Country' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(T.Usd, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) + SUM(ISNULL(T.Fee1, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(T.Usd, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) + SUM(ISNULL(T.Fee1, 0)) AS BalanceDetail
          FROM CountryTaxes T
          INNER JOIN Agencies A
            ON A.AgencyId = T.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND T.CardPayment = 1
          AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY T.AgencyId
                  ,CAST(T.CreationDate AS DATE)
          UNION ALL --PromotionalCodes
          SELECT
            C.AgencyId
           ,CAST(C.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'city sticker' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(C.USD, 0)) + SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.USD, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(C.USD, 0)) + SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.USD, 0)) AS BalanceDetail
          FROM dbo.PromotionalCodes AS PC
          INNER JOIN dbo.PromotionalCodesStatus AS PS
            ON PC.PromotionalCodeId = PS.PromotionalCodeId
          RIGHT OUTER JOIN dbo.CityStickers AS C
          INNER JOIN dbo.Agencies AS A
            ON A.AgencyId = C.AgencyId
            ON PS.CityStickerId = C.CityStickerId
          WHERE A.AgencyId = @AgencyId
          AND C.CardPayment = 1
          AND (CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          AND C.TitleParentId IS NULL --Only city stickers no child of titles,--Last update by JT/29-06-2024 TASK 5923 POINT 5

          GROUP BY C.AgencyId
                  ,CAST(C.CreationDate AS DATE)

          UNION ALL
          SELECT
            PL.AgencyId
           ,CAST(PL.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'plate sticker' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(PL.Usd, 0)) + SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(PL.Usd, 0)) + SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
          FROM dbo.PromotionalCodes AS PC
          INNER JOIN dbo.PromotionalCodesStatus AS PS
            ON PC.PromotionalCodeId = PS.PromotionalCodeId
          RIGHT OUTER JOIN dbo.PlateStickers AS PL
          INNER JOIN dbo.Agencies AS A
            ON A.AgencyId = PL.AgencyId
            ON PS.PlateStickerId = PL.PlateStickerId
          WHERE A.AgencyId = @AgencyId
          AND PL.CardPayment = 1
          AND (CAST(PL.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(PL.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY PL.AgencyId
                  ,CAST(PL.CreationDate AS DATE)
          UNION ALL
          SELECT
            TS.AgencyId
           ,CAST(TS.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'titles' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(TS.USD, 0)) + SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.USD, 0))
            + ISNULL((SELECT
                ISNULL(ISNULL(cs.USD, 0) + ISNULL(cs.Fee1, 0), 0) --Last update by JT/29-06-2024 TASK 5923 POINT 5
              FROM CityStickers cs
              WHERE cs.TitleParentId = TS.TitleId)
            , 0)
            AS Debit
           ,0 Credit
           ,SUM(ISNULL(TS.USD, 0)) + SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.USD, 0))
            + ISNULL((SELECT
                ISNULL(ISNULL(cs.USD, 0) + ISNULL(cs.Fee1, 0), 0) --Last update by JT/29-06-2024 TASK 5923 POINT 5
              FROM CityStickers cs
              WHERE cs.TitleParentId = TS.TitleId)
            , 0)
            AS BalanceDetail
          FROM dbo.PromotionalCodes AS PC
          INNER JOIN dbo.PromotionalCodesStatus AS PS
            ON PC.PromotionalCodeId = PS.PromotionalCodeId
          RIGHT OUTER JOIN dbo.Titles AS TS
          INNER JOIN dbo.Agencies AS A
            ON A.AgencyId = TS.AgencyId
            ON PS.TitleId = TS.TitleId
          WHERE A.AgencyId = @AgencyId
          AND TS.CardPayment = 1
          AND (CAST(TS.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(TS.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY TS.AgencyId
                  ,CAST(TS.CreationDate AS DATE)
                  ,TS.TitleId
          --UNION ALL ESTA SECCIÒN YA NO EXISTE
          --SELECT PK.AgencyId, 
          --       CAST(PK.CreationDate AS DATE) AS DATE, 
          --       'CLOSING DAILY' Description, 
          --       'CARD PAYMENT' Type, 
          --       --'parking ticket' Type, 
          --       COUNT(*) AS Transactions, 
          --       1 TypeId, 
          --       SUM(ISNULL(PK.Usd, 0)) + SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS Debit, 
          --       0 Credit, 
          --       SUM(ISNULL(PK.Usd, 0)) + SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS BalanceDetail
          --FROM Parkingticketscards PK
          --     INNER JOIN Agencies A ON A.AgencyId = PK.AgencyId
          --WHERE A.AgencyId = @AgencyId
          --      AND PK.cardpayment = 1
          --      AND CAST(PK.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          --      AND CAST(PK.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          --GROUP BY PK.AgencyId, 
          --         CAST(PK.CreationDate AS DATE)
          UNION ALL --Parkingtickets
          SELECT
            P.AgencyId
           ,CAST(P.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'parking ticket' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(P.USD, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(P.USD, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS BalanceDetail
          FROM ParkingTickets P
          INNER JOIN Agencies A
            ON A.AgencyId = P.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND P.CardPayment = 1
          AND (CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY P.AgencyId
                  ,CAST(P.CreationDate AS DATE)

          UNION ALL --Tickets
          SELECT
            PK.AgencyId
           ,CAST(PK.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'parking ticket' Type, 
            1 AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(PK.USD, 0)) + MAX(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(PK.USD, 0)) + MAX(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS BalanceDetail
          FROM Tickets PK
          INNER JOIN Agencies A
            ON A.AgencyId = PK.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND PK.CardPayment = 1
          AND (CAST(PK.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(PK.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY PK.AgencyId
                  ,CAST(PK.CreationDate AS DATE)
                  ,PK.TransactionGuid

          UNION ALL --titleInquiry
          SELECT
            TI.AgencyId
           ,CAST(TI.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'Inquiry' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(TI.USD, 0)) + SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(TI.USD, 0)) + SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS BalanceDetail
          FROM TitleInquiry TI
          INNER JOIN Agencies A
            ON A.AgencyId = TI.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND TI.CardPayment = 1
          AND (CAST(TI.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(TI.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY TI.AgencyId
                  ,CAST(TI.CreationDate AS DATE)


          UNION ALL --TRP
          SELECT
            TR.AgencyId
           ,CAST(TR.CreatedOn AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'Trp' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(TR.USD, 0)) + SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(TR.USD, 0)) + SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS BalanceDetail
          FROM TRP TR
          INNER JOIN Agencies A
            ON A.AgencyId = TR.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND TR.CardPayment = 1
          AND (CAST(TR.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(TR.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY TR.AgencyId
                  ,CAST(TR.CreatedOn AS DATE)

          UNION ALL --OtherPayments
          SELECT
            OP.AgencyId
           ,CAST(OP.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'OtherPayment' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(OP.USD, 0)) + SUM(ISNULL(OP.CardPaymentFee, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(OP.USD, 0)) + SUM(ISNULL(OP.CardPaymentFee, 0)) AS BalanceDetail
          FROM OtherPayments OP
          INNER JOIN Agencies A
            ON A.AgencyId = OP.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND OP.CardPayment = 1
          AND (CAST(OP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(OP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY OP.AgencyId
                  ,CAST(OP.CreationDate AS DATE)

          UNION ALL --OthersDetails
          SELECT
            OD.AgencyId
           ,CAST(OD.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'OtherDetails' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(OD.Usd, 0)) + SUM(ISNULL(OD.CardPaymentFee, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(OD.Usd, 0)) + SUM(ISNULL(OD.CardPaymentFee, 0)) AS BalanceDetail
          FROM OthersDetails OD
          INNER JOIN Agencies A
            ON A.AgencyId = OD.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND OD.CardPayment = 1
          AND (CAST(OD.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(OD.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY OD.AgencyId
                  ,CAST(OD.CreationDate AS DATE)

          UNION ALL --HeadphonesAndChargers
          SELECT
            HC.AgencyId
           ,CAST(HC.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,COUNT(*) AS Transactions
           ,1 TypeId
           ,CAST(SUM(ISNULL(HC.HeadphonesUsd, 0)) + SUM(ISNULL(HC.ChargersUsd, 0)) + SUM(ISNULL(HC.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS Debit
           ,0 Credit
           ,CAST(SUM(ISNULL(HC.HeadphonesUsd, 0)) + SUM(ISNULL(HC.ChargersUsd, 0)) + SUM(ISNULL(HC.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS BalanceDetail
          FROM HeadphonesAndChargers HC
          INNER JOIN Agencies A
            ON A.AgencyId = HC.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND HC.CardPayment = 1
          AND (CAST(HC.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(HC.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY HC.AgencyId
                  ,CAST(HC.CreationDate AS DATE)

          UNION ALL --PhoneSales
          SELECT
            A.AgencyId
           ,CAST(p.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,COUNT(*) AS Transactions
           ,1 TypeId
           ,CAST(SUM(ISNULL(p.SellingValue, 0)) + SUM(ISNULL(pp.Usd, 0)) + ((SUM(ISNULL(p.SellingValue, 0)) * SUM(ISNULL(p.Tax, 0))) / 100) + SUM(ISNULL(p.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS Debit
           ,0 Credit
           ,CAST(SUM(ISNULL(p.SellingValue, 0)) + SUM(ISNULL(pp.Usd, 0)) + ((SUM(ISNULL(p.SellingValue, 0)) * SUM(ISNULL(p.Tax, 0))) / 100) + SUM(ISNULL(p.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS BalanceDetail
          FROM PhoneSales p
          INNER JOIN InventoryByAgency IA
            ON IA.InventoryByAgencyId = p.InventoryByAgencyId
          INNER JOIN Agencies A
            ON A.AgencyId = IA.AgencyId
          LEFT JOIN PhonePlans pp
            ON pp.PhonePlanId = p.PhonePlanId
          WHERE A.AgencyId = @AgencyId
          AND p.CardPayment = 1
          AND (CAST(p.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(p.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY A.AgencyId
                  ,CAST(p.CreationDate AS DATE)

          UNION ALL --TicketFeeServices
          SELECT
            fs.AgencyId
           ,CAST(fs.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(fs.Usd, 0)) + SUM(ISNULL(fs.CardPaymentFee, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(fs.Usd, 0)) + SUM(ISNULL(fs.CardPaymentFee, 0)) AS BalanceDetail
          FROM TicketFeeServices fs
          INNER JOIN Agencies A
            ON A.AgencyId = fs.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND fs.UsedCard = 1
          AND (CAST(fs.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(fs.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY fs.AgencyId
                  ,CAST(fs.CreationDate AS DATE)

          UNION ALL --SYSTEM TOOLS
          SELECT
            s.AgencyId
           ,CAST(s.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,
            --'OtherPayment' Type, 
            COUNT(*) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(s.Total, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(s.Total, 0)) AS BalanceDetail
          FROM SystemToolsBill s
          INNER JOIN Agencies A
            ON A.AgencyId = s.AgencyId
          WHERE A.AgencyId = @AgencyId
          AND s.CardPayment = 1
          AND (CAST(s.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(s.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY s.AgencyId
                  ,CAST(s.CreationDate AS DATE)
          UNION ALL --CARD PAYMENTS
          SELECT
            s.AgencyId
           ,CAST(s.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,SUM(s.NumberPayments) AS Transactions
           ,1 TypeId
           ,SUM(ISNULL(s.Usd, 0)) + SUM(ISNULL(s.TotalPay, 0)) + SUM(ISNULL(s.Fee, 0)) + SUM(ISNULL(s.FeeUsd, 0)) AS Debit
           ,0 Credit
           ,SUM(ISNULL(s.Usd, 0)) + SUM(ISNULL(s.TotalPay, 0)) + SUM(ISNULL(s.Fee, 0)) + SUM(ISNULL(s.FeeUsd, 0)) AS BalanceDetail
          FROM CardPayments s
          INNER JOIN Agencies A
            ON A.AgencyId = s.AgencyId
          WHERE A.AgencyId = @AgencyId

          AND (CAST(s.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(s.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
          OR @ToDate IS NULL)
          GROUP BY s.AgencyId
                  ,CAST(s.CreationDate AS DATE)

          UNION ALL
          SELECT
            qi.AgencyId
           ,CAST(qi.CreationDate AS DATE) AS DATE
           ,'CLOSING DAILY' Description
           ,'CARD PAYMENT' Type
           ,COUNT(*) Transactions
           ,1 TypeId
           ,
            --				SUM(qi.Usd) AS Debit
            SUM(ISNULL((qi.Usd + qi.CardFee), 0)) Debit
           ,0 AS Credit
           ,SUM(qi.Usd + qi.CardFee) AS BalanceDetail
          FROM dbo.FN_GenerateInsuranceCardPaymentReport(@AgencyId, @FromDate, @ToDate, NULL, NULL, 0) qi
          GROUP BY qi.AgencyId
                  ,CAST(qi.CreationDate AS DATE)) AS QueryAnindado
        GROUP BY AgencyId
                ,CAST(Date AS DATE)
                ,Description
                ,Type
                ,
                 --Transactions,
                 TypeId
        --Debit, 
        --Credit, 
        --BalanceDetail

        UNION ALL --BANK PAYMENTS
        SELECT
          S.AgencyId
         ,CAST(S.FromDate AS DATE) AS DATE
         ,'**' + RIGHT(Ba.AccountNumber, 4) + ' ' + B.Name Description
         ,'BANK PAYMENTS' Type
         ,COUNT(*) Transactions
         ,2 TypeId
         ,SUM(ISNULL(C.Usd, 0)) AS Debit
         ,0 AS Credit
         ,SUM(ISNULL(C.Usd, 0)) AS BalanceDetail
        FROM ConciliationCardPayments S
        INNER JOIN ConciliationCardPaymentsDetails C
          ON S.ConciliationCardPaymentId = C.ConciliationCardPaymentId
        INNER JOIN BankAccounts Ba
          ON Ba.BankAccountId = S.BankAccountId
        INNER JOIN Bank B
          ON Ba.BankId = B.BankId
        INNER JOIN Agencies A
          ON A.AgencyId = S.AgencyId
        WHERE S.IsCredit = 0
        AND A.AgencyId = @AgencyId
        --AND s.creationdate = ''
        AND (CAST(S.FromDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(S.FromDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
        GROUP BY CAST(S.FromDate AS DATE)

                ,S.AgencyId
                ,Ba.AccountNumber
                ,B.Name
        UNION ALL
        -- Card payments (debit)
        SELECT
          dbo.PaymentOthers.AgencyId
         ,CAST(dbo.PaymentOthers.Date AS DATE) AS DATE
         ,'CARD PAYMENT CREDIT' AS Description
         ,'CARD PAYMENT' AS Type
         ,COUNT(*) Transactions
         ,1 TypeId
         ,0 AS Debit
         ,0 + SUM(USD) AS Credit
         ,-SUM(USD) AS BalanceDetail
        FROM dbo.PaymentOthers
        WHERE dbo.PaymentOthers.DeletedOn IS NULL
        AND dbo.PaymentOthers.DeletedBy IS NULL
        AND dbo.PaymentOthers.AgencyId = @AgencyId
        AND dbo.PaymentOthers.IsDebit = 1
        AND dbo.PaymentOthers.IsCardPayment = 1
        AND (CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
        GROUP BY CAST(dbo.PaymentOthers.Date AS DATE)
                ,dbo.PaymentOthers.AgencyId
        UNION ALL
        -- Card payments (CREDIT)
        SELECT
          dbo.PaymentOthers.AgencyId
         ,CAST(dbo.PaymentOthers.Date AS DATE) AS DATE
         ,'CARD PAYMENT DEBIT' AS Description
         ,'CARD PAYMENT' AS Type
         ,COUNT(*) Transactions
         ,2 TypeId
         ,0 + SUM(dbo.PaymentOthers.USD) AS Debit
         ,0 AS Credit
         ,+SUM(dbo.PaymentOthers.USD) AS BalanceDetail
        FROM dbo.PaymentOthers
        WHERE dbo.PaymentOthers.DeletedOn IS NULL
        AND dbo.PaymentOthers.DeletedBy IS NULL
        AND dbo.PaymentOthers.AgencyId = @AgencyId
        AND dbo.PaymentOthers.IsDebit = 0
        AND dbo.PaymentOthers.IsCardPayment = 1
        AND (CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
        GROUP BY CAST(dbo.PaymentOthers.Date AS DATE)
                ,dbo.PaymentOthers.AgencyId
        UNION ALL
        SELECT
          S.AgencyId
         ,CAST(S.FromDate AS DATE) AS DATE
         ,'**' + RIGHT(Ba.AccountNumber, 4) + ' ' + B.Name Description
         ,'BANK PAYMENTS' Type
         ,COUNT(*) Transactions
         ,2 TypeId
         ,0 AS Debit
         ,SUM(ISNULL(C.USD, 0)) AS Credit
         ,-SUM(ISNULL(C.USD, 0)) AS BalanceDetail
        FROM ConciliationCardPayments S
        INNER JOIN ConciliationCardPaymentsDetails C
          ON S.ConciliationCardPaymentId = C.ConciliationCardPaymentId
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
        GROUP BY CAST(S.FromDate AS DATE)
                ,S.AgencyId
                ,Ba.AccountNumber
                ,B.Name
      --				UNION ALL
      --				SELECT 
      --				qi.AgencyId,
      --				CAST(qi.CreationDate AS DATE) AS DATE,
      --				'CLOSING DAILY' Description,
      --				'CARD PAYMENT' Type,
      --				COUNT(*) Transactions,
      --				1 TypeId,
      --				SUM(qi.Usd) AS Debit
      --         ,0 AS Credit
      --         ,SUM(qi.Usd) AS BalanceDetail
      --				FROM
      --				dbo.FN_GenerateInsuranceCardPaymentReport(@AgencyId,@FromDate,@ToDate) qi
      --				GROUP BY qi.AgencyId, CAST(qi.CreationDate AS DATE)
      ) AS Query) AS QueryFinal
    ORDER BY RowNumberDetail ASC;



  INSERT INTO @result (RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  Transactions,
  TypeId,
  Debit,
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