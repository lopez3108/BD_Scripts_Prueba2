SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportMoneyDistributionDetail]
(
                 @AgencyId int, @FromDate datetime = NULL, @ToDate datetime = NULL, @Date datetime
)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
--
--  IF OBJECT_ID('#TempTableMoneyDistributionDetail') IS NOT NULL
--  BEGIN
--    DROP TABLE #TempTableMoneyDistributionDetail;
--  END;
 -- INITIAL BALANCE

  DECLARE @initialBalanceFinalDate datetime
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance decimal(18, 2)
  SET @Balance = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
FROM dbo.FN_GetReportMoneyDistributionDetail(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)




  CREATE TABLE #TempTableMoneyDistributionDetail
  (
              RowNumber int,
              AgencyId int,
              Date datetime,
              Type varchar(1000),
              TypeId int,
              Description varchar(1000),
              PackageNumber varchar(1000),
              Debit decimal(18, 2),
              Credit decimal(18, 2),
              BalanceDetail decimal(18, 2)
  );

  INSERT INTO #TempTableMoneyDistributionDetail 
         SELECT 0 RowNumber,
         NULL AgencyId,
         CAST(@initialBalanceFinalDate AS date) Date,
         'INITIAL BALANCE' Type,
         0 TypeId,
         'INITIAL BALANCE' Description,
         '-' PackageNumber,
         0 Debit,
         0 Credit,
         ISNULL(@Balance, 0) BalanceDetail

   UNION ALL

  SELECT *
         FROM [dbo].FN_GetReportMoneyDistributionDetail(@AgencyId, @FromDate, @ToDate)
         ORDER BY Date,
         RowNumber;

--         SELECT *
--         FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query1.TypeId ASC, CAST(Query1.Date AS date) ASC) RowNumber, *
--       FROM (SELECT d.AgencyId, CAST(d.CreationDate AS date) AS Date, 'CLOSING DAILY' AS Type, 1 AS TypeId, u.Name AS Description, '' AS PackageNumber, d.Cash AS Debit, 0 AS Credit, d.Cash BalanceDetail
--     FROM DailyDistribution dd
--          INNER JOIN
--          Daily d
--          ON d.DailyId = dd.DailyId
--          INNER JOIN
--          Agencies a
--          ON a.AgencyId = d.AgencyId
--          INNER JOIN
--          Cashiers c
--          ON c.CashierId = d.CashierId
--          INNER JOIN
--          Users u
--          ON u.UserId = c.UserId
--     WHERE d.AgencyId = @AgencyId AND
--           (CAST(d.CreationDate AS date) >= CAST(@FromDate AS date) OR
--           @FromDate IS NULL) AND
--           (CAST(d.CreationDate AS date) <= CAST(@ToDate AS date) OR
--           @ToDate IS NULL)
--     GROUP BY d.Cash, c.CashierId, CAST(d.CreationDate AS date), d.AgencyId, u.Name
--     UNION ALL
--     SELECT d.AgencyId, CAST(d.CreationDate AS date) AS Date, 'MONEY DISTRIBUTION' AS Type, CASE WHEN dd.ProviderId IS NOT NULL THEN 2 WHEN dd.BankAccountId IS NOT NULL THEN 3 END AS TypeId, CASE WHEN dd.ProviderId IS NOT NULL THEN p.Name + ' ' + m.Number WHEN dd.BankAccountId IS NOT NULL THEN 'BANK - ' + RIGHT(Ba.AccountNumber, 4) + ' (' + B.Name + ')' END AS Description, PackageNumber, 0 AS Debit, dd.USD AS Credit, -dd.USD BalanceDetail
--     FROM DailyDistribution dd
--          INNER JOIN
--          Daily d
--          ON d.DailyId = dd.DailyId
--
--          LEFT JOIN
--          Providers p
--          ON p.ProviderId = dd.ProviderId
--          LEFT JOIN
--          MoneyTransferxAgencyNumbers m
--          ON m.ProviderId = dd.ProviderId
--            AND
--            m.AgencyId = dd.AgencyId
--          LEFT JOIN
--          BankAccounts Ba
--          ON Ba.BankAccountId = dd.BankAccountId
--          LEFT JOIN
--          Bank B
--          ON B.BankId = Ba.BankId
--     WHERE d.AgencyId = @AgencyId AND
--           (CAST(d.CreationDate AS date) >= CAST(@FromDate AS date) OR
--           @FromDate IS NULL) AND
--           (CAST(d.CreationDate AS date) <= CAST(@ToDate AS date) OR
--           @ToDate IS NULL)) AS Query1) AS Query2;


--  SELECT *, (SELECT SUM(t2.BalanceDetail)
--FROM #TempTableMoneyDistributionDetail t2
--WHERE t2.RowNumber <= t1.RowNumber) BalanceFinal
--  FROM #TempTableMoneyDistributionDetail t1
--  ORDER BY RowNumber ASC;
	SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
              FROM #TempTableMoneyDistributionDetail t2
              WHERE t2.RowNumber <= t1.RowNumber
          ) BalanceFinal
          	
  				 FROM #TempTableMoneyDistributionDetail T1



END;




GO