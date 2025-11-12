SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportElsGeneralDetail]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
BEGIN
 DECLARE @FromDateInitial AS DATETIME;
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        SET @FromDateInitial = DATEADD(day, -1, @FromDate);


--  DECLARE @agencyInitialBalance DECIMAL(18, 2)
--  DECLARE @BalanceDetail DECIMAL(18, 2)
--  SET @agencyInitialBalance = ISNULL((SELECT TOP 1
--      InitialBalance
--    FROM ElsxAgencyInitialBalances
--    WHERE AgencyId = @AgencyId)
--  , 0)

--  SET @BalanceDetail = ISNULL(@agencyInitialBalance + (SELECT
--      SUM(BalanceDetail)
--    FROM dbo.FN_GenerateReportElsGeneralDetail(@AgencyId, '1985-01-01', @FromDateInitial)), 0)


 CREATE TABLE #Temp 
  (
           [ID] INT IDENTITY(1,1),
           [Index]        INT, 
           AgencyId       INT, 
           Date           DATETIME, 
           Description    VARCHAR(1000), 
           Employee       VARCHAR(1000), 
           Type           VARCHAR(1000), 
           TypeId         INT, 
           Transactions   INT, 
           Usd            DECIMAL(18, 2), 
           FeeService     DECIMAL(18, 2), 
           FeeEls         DECIMAL(18, 2), 
           CommissionsEls DECIMAL(18, 2), 
           BalanceDetail  DECIMAL(18, 2)
               
  )


--	INSERT INTO #Temp
--                 SELECT 1 [Index], 
--                         @AgencyId AgencyId, 
--                                CAST(@FromDateInitial AS DATE) Date, 
--                                'INITIAL BALANCE' Description, 
--                                '' AS Employee, 
--                                'INITIAL BALANCE' Type, 
--                                0 TypeId, 
--                                0 Transactions, 
--                                0 Usd, 
--                                0 FeeService, 
--                                0 FeeEls, 
--                                0 CommissionsEls, 
--                                @BalanceDetail BalanceDetail
--  			
--         UNION ALL

          SELECT *
          FROM [dbo].FN_GenerateReportElsGeneralDetail(@AgencyId, @FromDate, @ToDate)
          ORDER BY Date, 
                   [Index];
  
  				
  				
  				SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18,2))), 0)
              FROM    #Temp T2
              WHERE T2.ID <= T1.ID
          ) BalanceFinal
       
  				 FROM #Temp T1
  
  				 DROP TABLE #Temp




END


--    BEGIN
--        DECLARE @FromDateInitial AS DATETIME;
--        IF(@FromDate IS NULL)
--            BEGIN
--                SET @FromDate = DATEADD(day, -10, @Date);
--                SET @ToDate = @Date;
--            END;
--        SET @FromDateInitial = DATEADD(day, -1, @FromDate);
--        IF OBJECT_ID('#TempTableElsFinal') IS NOT NULL
--            BEGIN
--                DROP TABLE #TempTableElsFinal;
--            END;
--        CREATE TABLE #TempTableElsFinal
--        (RowNumber      INT, 
--         AgencyId       INT, 
--         Date           DATETIME, 
--         Description    VARCHAR(1000), 
--         Employee       VARCHAR(1000), 
--         Type           VARCHAR(1000), 
--         TypeId         INT, 
--         Transactions   INT, 
--         Usd            DECIMAL(18, 2), 
--         FeeService     DECIMAL(18, 2), 
--         FeeEls         DECIMAL(18, 2), 
--         CommissionsEls DECIMAL(18, 2), 
--         BalanceDetail  DECIMAL(18, 2)
--        );
--        IF OBJECT_ID('#TempTableEls') IS NOT NULL
--            BEGIN
--                DROP TABLE #TempTableEls;
--            END;
--        CREATE TABLE #TempTableEls
--        (AgencyId       INT, 
--         Date           DATETIME, 
--         Description    VARCHAR(1000), 
--         Employee       VARCHAR(1000), 
--         Type           VARCHAR(1000), 
--         TypeId         INT, 
--         Transactions   INT, 
--         Usd            DECIMAL(18, 2), 
--         FeeService     DECIMAL(18, 2), 
--         FeeEls         DECIMAL(18, 2), 
--         CommissionsEls DECIMAL(18, 2), 
--         BalanceDetail  DECIMAL(18, 2)
--        );
--        INSERT INTO #TempTableEls
--        (AgencyId, 
--         Date, 
--         Description, 
--         Employee, 
--         Type, 
--         TypeId, 
--         Transactions, 
--         Usd, 
--         FeeService, 
--         FeeEls, 
--         CommissionsEls, 
--         BalanceDetail
--        )
--               SELECT *
--               FROM
--               (
--                   SELECT TOP 1 AgencyId, 
--                                CAST(@FromDateInitial AS DATE) Date, 
--                                'INITIAL BALANCE' Description, 
--                                '' AS Employee, 
--                                'INITIAL BALANCE' Type, 
--                                0 TypeId, 
--                                0 Transactions, 
--                                Balance Usd, 
--                                0 FeeService, 
--                                0 FeeEls, 
--                                0 CommissionsEls, 
--                                Balance BalanceDetail
--                   FROM dbo.[FN_GenerateBalanceElsSales](@AgencyId, NULL, @FromDateInitial)
--                   ORDER BY RowNumberDetail DESC
--                   UNION ALL
--                   SELECT S.AgencyId, 
--                          CAST(S.CreationDate AS DATE) AS DATE, 
--                          'CLOSING DAILY' Description, 
--                          u.Name AS Employee, 
--                          'CITY STICKER' Type, 
--                          1 TypeId, 
--                          COUNT(*) Transactions, 
--                          SUM(ISNULL(S.Usd, 0))  AS Usd, 
--                          SUM(ISNULL(S.Fee1, 0)) FeeService, 
--                          SUM(ISNULL(S.FeeEls, 0)) AS FeeEls, 
--                          SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls, 
--                          SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--                   FROM CityStickers S
--                        INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        INNER JOIN Users u ON u.UserId = s.CreatedBy
--                   WHERE A.AgencyId = @AgencyId
--                         AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              OR @FromDate IS NULL)
--                         AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              OR @ToDate IS NULL)
--                   GROUP BY S.AgencyId, 
--                            A.Name, 
--                            u.Name, 
--                            CAST(S.CreationDate AS DATE), 
--                            s.CityStickerId
--                   UNION ALL
--                   SELECT S.AgencyId, 
--                          CAST(S.CreationDate AS DATE) AS DATE, 
--                          'CLOSING DAILY' Description, 
--                          u.Name AS Employee, 
--                          'COUNTY TAX' Type, 
--                          2 TypeId, 
--                          COUNT(*) Transactions, 
--                          SUM(ISNULL(S.Usd, 0)) AS Usd, 
--                          SUM(ISNULL(S.Fee1, 0)) FeeService, 
--                          SUM(ISNULL(S.FeeEls, 0)) AS FeeEls, 
--                          SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls, 
--                          SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--            FROM CountryTaxes S
--                        INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        INNER JOIN Users u ON u.UserId = s.CreatedBy
--                   WHERE A.AgencyId = @AgencyId
--                         AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              OR @FromDate IS NULL)
--                         AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              OR @ToDate IS NULL)
--                   GROUP BY S.AgencyId, 
--                            A.Name, 
--                            u.Name, 
--                            CAST(S.CreationDate AS DATE), 
--                            s.CountryTaxId
--                   --UNION ALL
--                   --SELECT S.AgencyId,
--                   --       CAST(S.CreationDate AS DATE) AS DATE,
--                   --       'CLOSING DAILY' Description,
--                   --       'PARKING TICKET CARD' Type,
--                   --       3 TypeId,
--                   --       COUNT(*) Transactions,
--                   --       SUM(ISNULL(S.USD, 0)) + SUM(ISNULL(S.Fee1, 0)) AS Debit, --Usd + feeState(fee1)
--                   --       0 AS Credit,
--                   --       SUM(ISNULL(S.USD, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--                   --FROM ParkingTicketsCards S
--                   --     INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                   --WHERE A.AgencyId = @AgencyId
--                   --      AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                   --           OR @FromDate IS NULL)
--                   --      AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                   --           OR @ToDate IS NULL)
--                   --GROUP BY S.AgencyId,
--                   --         A.Name,
--                   --         CAST(S.CreationDate AS DATE)
--                   UNION ALL
--                   SELECT S.AgencyId, 
--                          CAST(S.CreationDate AS DATE) AS DATE, 
--                          'CLOSING DAILY' Description, 
--                          u.Name AS Employee, 
--                          'PARKING TICKET ELS' Type, 
--                          4 TypeId, 
--                          COUNT(*) Transactions, 
--                          SUM(ISNULL(S.Usd, 0)) AS Usd, 
--                          SUM(ISNULL(S.Fee1, 0)) FeeService, 
--                          SUM(ISNULL(S.FeeEls, 0)) AS FeeEls, 
--                          SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls, 
--                          SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--                   FROM ParkingTickets S
--                        INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        INNER JOIN Users u ON u.UserId = s.CreatedBy
--                   WHERE A.AgencyId = @AgencyId
--                         AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              OR @FromDate IS NULL)
--                         AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              OR @ToDate IS NULL)
--                   GROUP BY S.AgencyId, 
--                            A.Name, 
--                            u.Name, 
--                            CAST(S.CreationDate AS DATE), 
--                            s.ParkingTicketId
--                   UNION ALL
--                   SELECT S.AgencyId, 
--                          CAST(S.CreationDate AS DATE) AS DATE, 
--                          'CLOSING DAILY' Description, 
--                          u.Name AS Employee, 
--                          'REGISTRATION RENEWALS' Type, 
--                          5 TypeId, 
--                          COUNT(*) Transactions, 
--                          SUM(ISNULL(S.Usd, 0)) AS Usd, 
--                          SUM(ISNULL(S.Fee1, 0)) FeeService, 
--                          SUM(ISNULL(S.FeeEls, 0)) AS FeeEls, 
--                          SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls, 
--                          SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--                   FROM PlateStickers S
--                        INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        INNER JOIN Users u ON u.UserId = s.CreatedBy
--                   WHERE A.AgencyId = @AgencyId
--                         AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              OR @FromDate IS NULL)
--                         AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              OR @ToDate IS NULL)
--                   GROUP BY S.AgencyId, 
--                            A.Name, 
--                            u.Name, 
--                            CAST(S.CreationDate AS DATE), 
--                            s.PlateStickerId
--                   UNION ALL
--                   SELECT S.AgencyId, 
--                          CAST(S.CreationDate AS DATE) AS DATE, 
--                          'CLOSING DAILY' Description, 
--                          u.Name AS Employee, 
--                          'TITLE AND PLATES' Type, 
--                          7 TypeId, 
--                          COUNT(*) Transactions, 
--                          SUM(ISNULL(S.Usd, 0))  AS Usd, 
--                          SUM(ISNULL(S.Fee1, 0)) FeeService, 
--                          SUM(ISNULL(S.FeeEls, 0)) AS FeeEls, 
--                          SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls, 
--                          SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--                   FROM Titles S
--                        INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        INNER JOIN Users u ON u.UserId = s.CreatedBy
--                   WHERE S.ProcessAuto = 1
--                         AND A.AgencyId = @AgencyId
--                         AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              OR @FromDate IS NULL)
--                         AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              OR @ToDate IS NULL)
--                   GROUP BY S.AgencyId, 
--                            A.Name, 
--                            u.Name, 
--                            CAST(S.CreationDate AS DATE), 
--                            s.TitleId
--                   UNION ALL
--                   SELECT S.AgencyId, 
--                          CAST(S.CreationDate AS DATE) AS DATE, 
--                          'CLOSING DAILY' Description, 
--                          u.Name AS Employee, 
--                          'TITLE INQUIRY' Type, 
--                          8 TypeId, 
--                          COUNT(*) Transactions, 
--                          SUM(ISNULL(S.Usd, 0)) AS Usd, 
--                          SUM(ISNULL(S.Fee1, 0)) FeeService, 
--                          SUM(ISNULL(S.FeeEls, 0)) AS FeeEls, 
--                          SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls, 
--                          SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
--                   FROM TitleInquiry S
--                        INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
--                        INNER JOIN Users u ON u.UserId = s.CreatedBy
--                   WHERE A.AgencyId = @AgencyId
--                         AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              OR @FromDate IS NULL)
--                         AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              OR @ToDate IS NULL)
--                   GROUP BY S.AgencyId, 
--                            A.Name, 
--                            u.Name, 
--                            CAST(S.CreationDate AS DATE), 
--                            s.TitleInquiryId
--               ) AS Query;
--        INSERT INTO #TempTableElsFinal
--        (RowNumber, 
--         AgencyId, 
--         Date, 
--         Description, 
--         Employee, 
--         Type, 
--         TypeId, 
--         Transactions, 
--         Usd, 
--         FeeService, 
--         FeeEls, 
--         CommissionsEls, 
--         BalanceDetail
--        )
--               SELECT *
--               FROM
--               (
--                   SELECT ROW_NUMBER() OVER(
--                          ORDER BY CAST(Query.Date AS DATE) ASC, 
--                                   Query.TypeId ASC) RowNumber, 
--                          *
--                   FROM
--                   (
--                       SELECT *
--                       FROM #TempTableEls
--                   ) AS Query
--               ) AS QueryFinal;
--        SELECT *, 
--        (
--            SELECT SUM(t2.BalanceDetail)
--            FROM #TempTableElsFinal t2
--            WHERE T2.RowNumber <= T1.RowNumber
--        ) BalanceFinal
--        FROM #TempTableElsFinal t1
--        ORDER BY RowNumber ASC;
--    END;




GO