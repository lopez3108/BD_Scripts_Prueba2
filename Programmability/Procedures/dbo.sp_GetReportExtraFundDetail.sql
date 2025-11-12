SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:18-10-2023
--CAMBIOS EN 5418, Refactoring reporte de extra fund
CREATE PROCEDURE [dbo].[sp_GetReportExtraFundDetail] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = ISNULL((SELECT
      SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
    FROM dbo.FN_GenerateBalanceExtraFundDetail(@AgencyId, '1985-01-01', @initialBalanceFinalDate, 1)),0)


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,ExtraFundId INT
   ,AgencyId INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,TypeId INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)

  )


  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,0 ExtraFundId
     ,@AgencyId AgencyId
     ,CAST(@initialBalanceFinalDate AS Date) Date
     ,'INITIAL BALANCE' Type
     ,'INITIAL BALANCE' Description
     ,0 TypeId
     ,0 Debit
     ,0 Credit
     ,@BalanceDetail BalanceDetail

    UNION ALL
    SELECT
      *
    FROM [dbo].FN_GenerateBalanceExtraFundDetail(@AgencyId, @FromDate, @ToDate, 2)
    ORDER BY Date,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID
      AND (T2.BalanceDetail > 0
      OR T2.BalanceDetail < 0))
    BalanceFinal
  FROM #Temp T1
--  WHERE (T1.BalanceDetail > 0
--  OR T1.BalanceDetail < 0)
  ORDER BY T1.Date, T1.ID ASC;
  DROP TABLE #Temp

END


--     IF(@FromDate IS NULL)
--         BEGIN
--             SET @FromDate = DATEADD(day, -10, @Date);
--     END;
--     DECLARE @FromDateInitial AS DATETIME;
--     SET @FromDateInitial = DATEADD(day, -1, @FromDate);
--     IF OBJECT_ID('#TempTableExtraFundFinal') IS NOT NULL
--         BEGIN
--             DROP TABLE #TempTableExtraFundFinal;
--     END;
--     CREATE TABLE #TempTableExtraFundFinal
--     (RowNumber       INT,
--      RowNumberDetail INT,
--      ExtraFundId     INT,
--      AgencyId        INT,
--      Date            DATETIME,
--      Type            VARCHAR(1000),
--      Description     VARCHAR(1000),
--      TypeId          INT,
--      Debit           DECIMAL(18, 2),
--      Credit          DECIMAL(18, 2),
--      BalanceDetail   DECIMAL(18, 2),
--      Balance         DECIMAL(18, 2)
--     );
--     IF OBJECT_ID('#TempTableExtraFunds') IS NOT NULL
--         BEGIN
--             DROP TABLE #TempTableExtraFunds;
--     END;
--     CREATE TABLE #TempTableExtraFunds
--     (RowNumberDetail INT,
--      ExtraFundId     INT,
--      AgencyId        INT,
--      Date            DATETIME,
--      Type            VARCHAR(100),
--      Description     VARCHAR(1000),
--      TypeId          INT,
--      Debit           DECIMAL(18, 2),
--      Credit          DECIMAL(18, 2),
--      BalanceDetail   DECIMAL(18, 2),
--      Balance         DECIMAL(18, 2)
--     );
--     INSERT INTO #TempTableExtraFunds
--     (RowNumberDetail,
--      ExtraFundId,
--      AgencyId,
--      Date,
--      Type,
--      Description,
--      TypeId,
--      Debit,
--      Credit,
--      BalanceDetail,
--      Balance
--     )
--            SELECT *
--            FROM
--            (
--                SELECT TOP 1 RowNumberDetail,
--                             0 ExtraFundId,
--                             AgencyId,
--                             CAST(@FromDateInitial AS DATE) Date,
--                             'INITIAL BALANCE' Type,
--                             'INITIAL BALANCE' Description,
--                             0 TypeId,
--                             0 Debit,
--                             0 Credit,
--                             Balance BalanceDetail,
--                             Balance
--                FROM dbo.FN_GenerateBalanceExtraFundDetail(@AgencyId, NULL, @FromDateInitial, 1)
--                ORDER BY RowNumberDetail DESC
--                UNION ALL
--                SELECT *
--                FROM dbo.FN_GenerateBalanceExtraFundDetail(@AgencyId, @FromDate, @ToDate, 2)
--
----                SELECT e.ExtraFundId,
----                       e.CreationDate Date,
----                       CASE
----                           WHEN c.CashierId IS NOT NULL
----                           THEN 'CASHIER'
----                           ELSE 'ADMIN'
----                       END Type,
----                       U.Name Description,
----                       1 TypeId,
----                       e.Usd Debit,
----                       0 Credit,
----                       e.Usd BalanceDetail
----                FROM EXTRAFUND E
----                     INNER JOIN Users U ON U.UserId = E.CreatedBy
----                     LEFT JOIN Cashiers c ON U.UserId = c.UserId
------WHERE CREATEDBY = 6
----                UNION ALL
----                SELECT e.ExtraFundId,
----                       e.CreationDate Date,
----                       CASE
----                           WHEN c.CashierId IS NOT NULL
----                           THEN 'CASHIER'
----                           ELSE 'ADMIN'
----                       END Type,
----                       U.Name Description,
----                       1 TypeId,
----                       0 Debit,
----                       e.Usd Credit,
----                       -e.Usd BalanceDetail
----                FROM EXTRAFUND e
----                     INNER JOIN Users U ON U.UserId = E.AssignedTo
----                     LEFT JOIN Cashiers c ON U.UserId = c.UserId
----WHERE AssignedTo = 6;
--            ) AS QUERY;
--     INSERT INTO #TempTableExtraFundFinal
--     (RowNumber,
--      RowNumberDetail,
--      ExtraFundId,
--      AgencyId,
--      Date,
--      Type,
--      Description,
--      TypeId,
--      Debit,
--      Credit,
--      BalanceDetail,
--      Balance
--     )
--            SELECT *
--            FROM
--            (
--                SELECT ROW_NUMBER() OVER(ORDER BY Query.ExtraFundId ASC,
--                                                  Query.TypeId ASC,
--                                                  CAST(Query.Date AS DATE) ASC) RowNumber,
--                       *
--                FROM
--                (
--                    SELECT *
--                    FROM #TempTableExtraFunds
--                ) AS Query
--            ) AS QueryFinal;
--     SELECT *,
--     (
--         SELECT SUM(t2.BalanceDetail)
--         FROM #TempTableExtraFundFinal t2
--         WHERE T2.RowNumber <= T1.RowNumber
--     ) BalanceFinal
--     FROM #TempTableExtraFundFinal t1
--     ORDER BY RowNumber ASC;



GO