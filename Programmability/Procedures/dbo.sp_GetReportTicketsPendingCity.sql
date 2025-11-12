SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportTicketsPendingCity]
(@AgencyId   INT, 
 @FromDate   DATETIME   = NULL, 
 @ToDate     DATETIME   = NULL, 
 @Date       DATETIME, 
 @CodeFilter VARCHAR(3) = NULL
)
AS
    BEGIN
        DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT;
        IF(@FromDate IS NULL and @CodeFilter = 'C02')
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
        SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
        SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
        SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
        SET @ProviderId =
        (
            SELECT ProviderId
            FROM Providers
                 INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
            WHERE ProviderTypes.Code = 'C24'
        );
        IF OBJECT_ID('#TempTable') IS NOT NULL
            BEGIN
                DROP TABLE #TempTable;
            END;

        --DROP TABLE #TempTable;
        CREATE TABLE #TempTable
        (RowNumber     INT, 
         --TicketId       INT,
         Date          DATETIME, 
         Agency        VARCHAR(1000), 
         Description   VARCHAR(1000), 
         Name          VARCHAR(1000), 
         Details       VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Transactions  INT, 
         USD           DECIMAL(18, 2), 
         Fee1          DECIMAL(18, 2), 
         Fee2          DECIMAL(18, 2), 
         FeeServices   DECIMAL(18, 2), 
         MoneyOrderFee DECIMAL(18, 2), 
         Pago          DECIMAL(18, 2), 
         SumDetail     DECIMAL(18, 2)
        );
        INSERT INTO #TempTable
        (RowNumber,
         --TicketId,
         Date, 
         Agency, 
         Description, 
         Name, 
         Details, 
         Type, 
         Transactions, 
         USD, 
         Fee1, 
         Fee2, 
         FeeServices, 
         MoneyOrderFee, 
         Pago, 
         SumDetail
        )
               SELECT *
               FROM
               (
                   SELECT ROW_NUMBER() OVER(
                          ORDER BY CAST(Query.Date AS DATE) ASC, 
                                   Query.Type ASC) RowNumber, 
                          *
                   FROM
                   (
                       SELECT 
                       --t.TicketId,
                       CAST(t.CreationDate AS DATE) Date, 
                       a.code Agency, 
                       'CLOSING DAILY' Description, 
                       U.Name, 
                       'TRAFFIC TICKETS' Details, 
                       1 Type, 
                       COUNT(*) Transactions, 
                       SUM(t.Usd) USD, 
                       SUM(t.Fee1) Fee1, 
                       SUM(t.Fee2) Fee2, 
                       0 FeeServices, 
                       0 MoneyOrderFee, 
                       0 Pago, 
                       (SUM(t.Usd) + SUM(t.Fee1) + SUM(t.Fee2)) SumDetail
                       FROM Tickets t
                            INNER JOIN Agencies A ON a.AgencyId = t.AgencyId
                            INNER JOIN dbo.Users U ON U.UserId = t.CreatedBy
                            INNER JOIN TicketStatus TS ON TS.TicketStatusId = T.TicketStatusId
                       WHERE   ((@CodeFilter = 'C01')
                                                              OR (@CodeFilter = 'C02'
                                                                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                                                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE))) 
					   and a.AgencyId = @AgencyId
                           
                             AND TS.Code = 'C00'
                       GROUP BY t.TicketId,
                                --a.Name, 
                                U.Name, 
                                a.code, 
                                --A.AgencyId, 
                                CAST(t.CreationDate AS DATE)
                
                   ) AS Query
               ) AS QueryFinal;


        CREATE TABLE #TempTable2
        (RowNumber     INT, 
         Date          DATETIME, 
         Agency        VARCHAR(1000), 
         Description   VARCHAR(1000), 
         Name          VARCHAR(1000), 
         Details       VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Transactions  INT, 
         USD           DECIMAL(18, 2), 
         Fee1          DECIMAL(18, 2), 
         Fee2          DECIMAL(18, 2), 
         FeeServices   DECIMAL(18, 2), 
         MoneyOrderFee DECIMAL(18, 2), 
         Pago          DECIMAL(18, 2), 
         SumDetail     DECIMAL(18, 2), 
         Balance       DECIMAL(18, 2)
        );


-- Comentado por decision de Jorge ya que las Commissiones  solo se deben de mostrar en GetReportTickets y GetReportTicketsDetails

--        CREATE TABLE #TempTableCommission
--        (CreationDate DATETIME, 
--         Month        INT, 
--         Year         INT, 
--         Usd          DECIMAL(18, 2), 
--         Agency       VARCHAR(1000)
--        );
--        INSERT INTO #TempTableCommission
--        (CreationDate, 
--         Month, 
--         Year, 
--         Usd, 
--         Agency
--        )
--               SELECT ProviderCommissionPayments.CreationDate, 
--                      ProviderCommissionPayments.Month, 
--                      ProviderCommissionPayments.Year, 
--                      ISNULL(ProviderCommissionPayments.Usd, 0) Usd, 
--                      dbo.Agencies.code + ' - ' + dbo.Agencies.Name
--               FROM dbo.ProviderCommissionPayments
--                    INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
--                    INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
--                    INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
--                    LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
--                    INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
--               WHERE ProviderCommissionPayments.AgencyId = @AgencyId
--                     AND ProviderCommissionPayments.Year >= @YearFrom
--                     AND ProviderCommissionPayments.Month >= @MonthFrom
--                     AND ProviderCommissionPayments.Year <= @YearTo
--                     AND ProviderCommissionPayments.Month <= @MonthTo
--                     AND ProviderCommissionPayments.ProviderId = @ProviderId;


--
--        IF EXISTS
--        (
--            SELECT 1
--            FROM #TempTableCommission
--        )
--            BEGIN 
--                --DROP TABLE #TempTable;
--
--                INSERT INTO #TempTable2
--                (RowNumber, 
--                 Date, 
--                 Agency, 
--                 Description, 
--                 Name, 
--                 Details, 
--                 Type, 
--                 Transactions, 
--                 USD, 
--                 Fee1, 
--                 Fee2, 
--                 FeeServices, 
--                 MoneyOrderFee, 
--                 Pago, 
--                 SumDetail, 
--                 Balance
--                )
--                       SELECT *, 
--                       (
--                           SELECT SUM(t2.SumDetail)
--                           FROM #TempTable t2
--                           WHERE T2.RowNumber <= T1.RowNumber
--                       ) Balance
--                       FROM #TempTable t1;
--                SELECT *
--                FROM #TempTable2
--                UNION ALL
--                SELECT
--                (
--                    SELECT COUNT(*) + 1
--                    FROM #TempTable2
--                ), 
--                CAST(t.CreationDate AS DATE) Date, 
--                t.Agency, 
--                'COMMISSIONS ' + dbo.[fn_GetMonthByNum](T.Month) + '-' + CAST(T.Year AS CHAR(4)) Description, 
--                '' Name, 
--                --+CAST(T.Month AS CHAR(2))+'-'+CAST(T.Year AS CHAR(4)) Description,
--                'COMMISSIONS' Details, 
--                4 Type, 
--                1 Transactions, 
--                0 USD, 
--                0 Fee1, 
--                0 Fee2, 
--                0 FeeServices, 
--                0 MoneyOrderFee, 
--                T.Usd Pago, 
--                0 SumDetail, 
--                0 Balance
--                FROM #TempTableCommission T
--                ORDER BY RowNumber ASC;
--            END;
--
--
--            ELSE



            BEGIN 
                --DROP TABLE #TempTable;

                INSERT INTO #TempTable2
                (RowNumber, 
                 Date, 
                 Agency, 
                 Description, 
                 Name, 
                 Details, 
                 Type, 
                 Transactions, 
                 USD, 
                 Fee1, 
                 Fee2, 
                 FeeServices, 
                 MoneyOrderFee, 
                 Pago, 
                 SumDetail, 
                 Balance
                )
                       SELECT *, 
                       (
                           SELECT SUM(t2.SumDetail)
                           FROM #TempTable t2
                           WHERE T2.RowNumber <= T1.RowNumber
                       ) Balance
                       FROM #TempTable t1;
                SELECT *
                FROM #TempTable2
                ORDER BY RowNumber ASC;
            END;
    END;


GO