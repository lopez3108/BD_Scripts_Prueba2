SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:21-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
CREATE FUNCTION [dbo].[FN_GenerateBalanceElsCommissionsElCorp] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL
)
RETURNS @result TABLE (
  [Index] INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,TypeDetailId INT
 ,Transactions INT
 ,CommissionElCorp DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)

)
AS
BEGIN
  DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT;
         
       
         SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         SET @ProviderId =
         (
             SELECT TOP 1 ProviderId
             FROM Providers
                  INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
             WHERE ProviderTypes.Code = 'C05'
         );

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
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp
     ,0 AS Credit
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp
     ,0 AS Credit
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp
     ,0 AS Credit
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp
     ,0 AS Credit
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp
     ,0 AS Credit
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
     ,2 TypeId
     ,8 TypeDetailId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp
     ,0 AS Credit
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
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
  INSERT INTO @result
    SELECT
      8
     ,Agencies.AgencyId
      ,dbo.[fn_GetNextDayPeriod](Year, Month) DATE
--     ,ProviderCommissionPayments.CreationDate DATE
--     ,'COMMISSIONS ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description
  , 'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description

     ,'COMMISSION' Type
     ,2 TypeId
     ,1 TypeDetailId
     ,1 Transactions
     ,0 AS CommissionElCorp
     ,ISNULL(ProviderCommissionPayments.USD, 0) Credit
     ,-ISNULL(ProviderCommissionPayments.USD, 0) BalanceDetail
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
    WHERE ProviderCommissionPayments.AgencyId = @AgencyId
--    AND ((ProviderCommissionPayments.Year = @YearFrom
--    AND ProviderCommissionPayments.Month >= @MonthFrom)
--    OR (ProviderCommissionPayments.Year > @YearFrom)
--    OR @YearFrom IS NULL)
--    AND ((ProviderCommissionPayments.Year = @YearTo
--    AND ProviderCommissionPayments.Month <= @MonthTo)
--    OR (ProviderCommissionPayments.Year < @YearTo)
--    OR @YearTo IS NULL)
AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
                      OR @FromDate IS NULL)
                      AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
                      OR @ToDate IS NULL)        
    AND ProviderCommissionPayments.ProviderId = @ProviderId
  RETURN
END




--     BEGIN
--         DECLARE @TableReturn TABLE
--         (RowNumberDetail  INT,
--          AgencyId         INT,
--          Date             DATETIME,
--          Description      VARCHAR(1000),
--          Type             VARCHAR(1000),
--          TypeId           INT,
--          TypeDetailId     INT,
--          Transactions     INT,
--          CommissionElCorp DECIMAL(18, 2),
--          Credit           DECIMAL(18, 2),
--          BalanceDetail    DECIMAL(18, 2)
--         );
--         INSERT INTO @TableReturn
--         (RowNumberDetail,
--          AgencyId,
--          Date,
--          Description,
--          Type,
--          TypeId,
--          TypeDetailId,
--          Transactions,
--          CommissionElCorp,
--          Credit,
--          BalanceDetail
--         )
--                SELECT *
--                FROM
--                (
--                    SELECT ROW_NUMBER() OVER(ORDER BY Query.TypeId ASC,
--                                                      Query.TypeDetailId ASC,
--                                                      CAST(Query.Date AS DATE) desc) RowNumberDetail,
--                           *
--                    FROM
--                    (
--                        SELECT S.AgencyId,
--                               CAST(S.CreationDate AS DATE) AS DATE,
--                               'CLOSING DAILY' Description,
--                               'CITY STICKER' Type,
--                               1 TypeId,
--                               1 TypeDetailId,
--                               COUNT(*) Transactions,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp,
--                               0 AS Credit,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
--                        FROM CityStickers S
--                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        WHERE A.AgencyId = @AgencyId
--                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                                   OR @FromDate IS NULL)
--                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                                   OR @ToDate IS NULL)
--                        GROUP BY S.AgencyId,
--                                 A.Name,
--                                 CAST(S.CreationDate AS DATE)
--                         INSERT INTO @result
--                        SELECT S.AgencyId,
--                               CAST(S.CreationDate AS DATE) AS DATE,
--                               'CLOSING DAILY' Description,
--                               'COUNTY TAX' Type,
--                               1 TypeId,
--                               2 TypeDetailId,
--                               COUNT(*) Transactions,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp,
--                               0 AS Credit,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
--                        FROM CountryTaxes S
--                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        WHERE A.AgencyId = @AgencyId
--                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                                   OR @FromDate IS NULL)
--                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                                   OR @ToDate IS NULL)
--                        GROUP BY S.AgencyId,
--                                 A.Name,
--                                 CAST(S.CreationDate AS DATE)
--                        -- INSERT INTO @result
--                        --SELECT S.AgencyId,
--                        --       CAST(S.CreationDate AS DATE) AS DATE,
--                        --       'CLOSING DAILY' Description,
--                        --       'PARKING TICKET CARD' Type,
--                        --       1 TypeId,
--                        --       3 TypeDetailId,
--                        --       COUNT(*) Transactions,
--                        --        SUM(ISNULL(S.Fee2, 0)) AS CommissionElCorp,
--                        --       0 AS Credit,
--                        --       SUM(ISNULL(S.Fee2, 0)) AS BalanceDetail
--                        --FROM ParkingTicketsCards S
--                        --     INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        --WHERE A.AgencyId = @AgencyId
--                        --      AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                        --           OR @FromDate IS NULL)
--                        --      AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                        --           OR @ToDate IS NULL)
--                        --GROUP BY S.AgencyId,
--                        --         A.Name,
--                        --         CAST(S.CreationDate AS DATE)
--                         INSERT INTO @result
--                        SELECT S.AgencyId,
--                               CAST(S.CreationDate AS DATE) AS DATE,
--                               'CLOSING DAILY' Description,
--                               'PARKING TICKET ELS' Type,
--                               1 TypeId,
--                               4 TypeDetailId,
--                               COUNT(*) Transactions,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp,
--                               0 AS Credit,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
--                        FROM ParkingTickets S
--                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        WHERE A.AgencyId = @AgencyId
--                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                                   OR @FromDate IS NULL)
--                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                                   OR @ToDate IS NULL)
--                        GROUP BY S.AgencyId,
--                                 A.Name,
--                                 CAST(S.CreationDate AS DATE)
--                         INSERT INTO @result
--                        SELECT S.AgencyId,
--                               CAST(S.CreationDate AS DATE) AS DATE,
--                               'CLOSING DAILY' Description,
--                               'REGISTRATION RENEWALS' Type,
--                               1 TypeId,
--                               5 TypeDetailId,
--                               COUNT(*) Transactions,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp,
--                               0 AS Credit,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
--                        FROM PlateStickers S
--                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        WHERE A.AgencyId = @AgencyId
--                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                                   OR @FromDate IS NULL)
--                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                                   OR @ToDate IS NULL)
--                        GROUP BY S.AgencyId,
--                                 A.Name,
--                                 CAST(S.CreationDate AS DATE)
--                        
--                         INSERT INTO @result
--                        SELECT S.AgencyId,
--                               CAST(S.CreationDate AS DATE) AS DATE,
--                               'CLOSING DAILY' Description,
--                               'TITLE AND PLATES' Type,
--                               1 TypeId,
--                               7 TypeDetailId,
--                               COUNT(*) Transactions,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp,
--                               0 AS Credit,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
--                        FROM Titles S
--                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        WHERE S.ProcessAuto = 1
--                              AND A.AgencyId = @AgencyId
--                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                                   OR @FromDate IS NULL)
--                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                                   OR @ToDate IS NULL)
--                        GROUP BY S.AgencyId,
--                                 A.Name,
--                                 CAST(S.CreationDate AS DATE)
--                         INSERT INTO @result
--                        SELECT S.AgencyId,
--                               CAST(S.CreationDate AS DATE) AS DATE,
--                               'CLOSING DAILY' Description,
--                               'TITLE INQUIRY' Type,
--                               2 TypeId,
--                               8 TypeDetailId,
--                               COUNT(*) Transactions,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionElCorp,
--                               0 AS Credit,
--                               SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS BalanceDetail
--                        FROM TitleInquiry S
--                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        WHERE A.AgencyId = @AgencyId
--                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                                   OR @FromDate IS NULL)
--                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                                   OR @ToDate IS NULL)
--                        GROUP BY S.AgencyId,
--                                 A.Name,
--                                 CAST(S.CreationDate AS DATE)
--                         INSERT INTO @result
--                        SELECT Agencies.AgencyId,
--                               ProviderCommissionPayments.CreationDate DATE,
--                               'COMMISSIONS '+dbo.[fn_GetMonthByNum](Month)+'-'+CAST(Year AS CHAR(4)) Description,
--                               'COMMISSION' Type,
--                               2 TypeId,
--                               1 TypeDetailId,
--                               0 Transactions,
--                               0 AS CommissionElCorp,
--                               ISNULL(ProviderCommissionPayments.Usd, 0) Credit,
--                               -ISNULL(ProviderCommissionPayments.Usd, 0) BalanceDetail
--                        FROM dbo.ProviderCommissionPayments
--                             INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
--                             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
--                             INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
--                             LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
--                             INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
--                        WHERE ProviderCommissionPayments.AgencyId = @AgencyId
--                              AND ((ProviderCommissionPayments.Year = @YearFrom
--                                    AND ProviderCommissionPayments.Month >= @MonthFrom)
--                                   OR (ProviderCommissionPayments.Year > @YearFrom)
--                                   OR @YearFrom IS NULL)
--                              AND ((ProviderCommissionPayments.Year = @YearTo
--                                    AND ProviderCommissionPayments.Month <= @MonthTo)
--                                   OR (ProviderCommissionPayments.Year < @YearTo)
--                                   OR @YearTo IS NULL)
--                              AND ProviderCommissionPayments.ProviderId = @ProviderId
--                    ) AS Query
--                ) AS QueryFinal
--                ORDER BY RowNumberDetail ASC;
--         INSERT INTO @result
--         (RowNumberDetail,
--          AgencyId,
--          Date,
--          Description,
--          Type,
--          TypeId,
--          TypeDetailId,
--          Transactions,
--          CommissionElCorp,
--          Credit,
--          BalanceDetail,
--          Balance
--         )
--         (
--             SELECT *,
--             (
--                 SELECT SUM(t2.BalanceDetail)
--                 FROM @TableReturn t2
--                 WHERE T2.RowNumberDetail <= T1.RowNumberDetail
--             ) Balance
--             FROM @TableReturn t1
--         );
--         RETURN;
--     END;
GO