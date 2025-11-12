SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportClient] (@ClientId INT,
@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@Code VARCHAR(3))
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
  IF OBJECT_ID('#TempTableClient') IS NOT NULL
  BEGIN
    DROP TABLE #TempTableClient;
  END;
  CREATE TABLE #TempTableClient (
    RowNumber INT
   ,CreationDate DATETIME
   ,DateCheck DATETIME
   ,StoreId VARCHAR(1000)
   ,ClienteId VARCHAR(1000)
   ,Maker VARCHAR(1000)
   ,Routing VARCHAR(1000)
   ,Account VARCHAR(1000)
   ,CheckNumber VARCHAR(1000)
   ,BalanceDetail DECIMAL(18, 2)
  );
  INSERT INTO #TempTableClient (RowNumber,
  CreationDate,
  DateCheck,
  StoreId,
  ClienteId,
  Maker,
  Routing,
  Account,
  CheckNumber,
  BalanceDetail)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY
        CAST(Query.CreationDate AS DATE) ASC) RowNumber
       ,*
      FROM (SELECT
          ce1.CreationDate
         ,ce1.CheckDate AS DateCheck
         ,ag.Code + ' - ' + ag.Name AS StoreId
         ,ce.ClienteId AS ClienteId
         ,M.Name AS Maker
         ,c.Routing AS Routing
         ,c.Account AS Account
         ,ce1.CheckNumber AS CheckNumber
         ,SUM(ce1.Amount) AS BalanceDetail
        FROM Clientes ce
        INNER JOIN Checks c
          ON c.ClientId = ce.ClienteId
        INNER JOIN dbo.ChecksEls ce1
          ON c.CheckId = ce1.CheckId
        INNER JOIN Agencies ag
          ON ag.AgencyId = c.AgencyId
        INNER JOIN Makers M
          ON M.MakerId = c.Maker
        WHERE (ce.ClienteId = @ClientId)
        AND (

        (@Code = 'C01'
        AND CAST(ce1.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(ce1.CreationDate AS DATE) <= CAST(@ToDate AS DATE))

        OR (@Code = 'C02'
        AND CAST(ce1.CheckDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(ce1.CheckDate AS DATE) <= CAST(@ToDate AS DATE)))





        GROUP BY ce1.CheckNumber
                ,M.Name
                ,ag.Name
                ,ce.ClienteId
                ,ag.Code
                ,ce1.CreationDate
                ,ce1.CheckDate
                ,c.DateCheck
                ,
                 --								c.DateCashed,
                 c.Routing
                ,c.Account) AS Query) AS QueryFinal;
  SELECT
    *
   ,(SELECT
        SUM(t2.BalanceDetail)
      FROM #TempTableClient t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTableClient t1
  ORDER BY RowNumber ASC;
END;



GO