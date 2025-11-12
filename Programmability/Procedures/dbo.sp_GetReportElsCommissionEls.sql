SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:21-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
CREATE PROCEDURE [dbo].[sp_GetReportElsCommissionEls] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  DECLARE @FromDateInitial AS DATETIME;
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
  SET @FromDateInitial = DATEADD(DAY, -1, @FromDate);
  DECLARE @BalanceDetail DECIMAL(18,2)
  SET @BalanceDetail =   (SELECT SUM(BalanceDetail) FROM dbo.FN_GenerateBalanceElsCommissionsELS(@AgencyId, '1985-01-01', @FromDateInitial))

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,TypeDetailId INT
   ,Transactions INT
   ,FeeEls DECIMAL(18, 4)
   ,Credit DECIMAL(18, 4)
   ,BalanceDetail DECIMAL(18, 4)
--   ,Balance DECIMAL(18, 4)

  )



  -- EL INITIAL BALANCE ESTABA COMENTADO, NO TENIA EN CUENTA  INITIAL BALANCE CONFIGURADO EN VEHICLE SERVICE, SE PIDE NUEVAMENTE 5389
   


  INSERT INTO #Temp

SELECT  1 [Index],
                                           @AgencyId AgencyId,
                                           CAST(@FromDateInitial AS DATE) Date,
                                           'INITIAL BALANCE' Description,
                                           'INITIAL BALANCE' Type,
                                           0 TypeId,
                   0 TypeDetailId,
                                           0 Transactions,
                                           0 FeeEls,
                                           0 Credit,
                                           @BalanceDetail BalanceDetail
                                           union ALL

    SELECT
      *
    FROM [dbo].FN_GenerateBalanceElsCommissionsELS(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(BalanceDetail), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal

  FROM #Temp T1

  DROP TABLE #Temp



--        IF OBJECT_ID('#TempTableElsFinal') IS NOT NULL
--            BEGIN
--                DROP TABLE #TempTableElsFinal;
--            END;
--        CREATE TABLE #TempTableElsFinal
--        (RowNumber       INT, 
--         RowNumberDetail INT, 
--         AgencyId        INT, 
--         Date            DATETIME, 
--         Description     VARCHAR(1000), 
--         Type            VARCHAR(1000), 
--         TypeId          INT, 
--         TypeDetailId    INT, 
--         Transactions    INT, 
--         FeeEls          DECIMAL(18, 4), 
--         Credit          DECIMAL(18, 4), 
--         BalanceDetail   DECIMAL(18, 4), 
--         Balance         DECIMAL(18, 4)
--        );
--        IF OBJECT_ID('#TempTableEls') IS NOT NULL
--            BEGIN
--                DROP TABLE #TempTableEls;
--            END;
--        CREATE TABLE #TempTableEls
--        (RowNumberDetail INT, 
--         AgencyId        INT, 
--         Date            DATETIME, 
--         Description     VARCHAR(1000), 
--         Type            VARCHAR(1000), 
--         TypeId          INT, 
--         TypeDetailId    INT, 
--         Transactions    INT, 
--         FeeEls          DECIMAL(18, 4), 
--         Credit          DECIMAL(18, 4), 
--         BalanceDetail   DECIMAL(18, 4), 
--         Balance         DECIMAL(18, 4)
--        );
--        INSERT INTO #TempTableEls
--        (RowNumberDetail, 
--         AgencyId, 
--         Date, 
--         Description, 
--         Type, 
--         TypeId, 
--         TypeDetailId, 
--         Transactions, 
--         FeeEls, 
--         Credit, 
--         BalanceDetail, 
--         Balance
--        )
--               SELECT *
--               FROM
--               (
--                   --           SELECT TOP 1 RowNumberDetail,
--                   --                        AgencyId,
--                   --                        CAST(@FromDateInitial AS DATE) Date,
--                   --                        'INITIAL BALANCE' Description,
--                   --                        'INITIAL BALANCE' Type,
--                   --                        0 TypeId,
--                   --0 TypeDetailId,
--                   --                        0 Transactions,
--                   --                        0 FeeEls,
--                   --                        0 Credit,
--                   --                        Balance BalanceDetail,
--                   --                        Balance
--                   --           FROM dbo.[FN_GenerateBalanceElsCommissionsELS](@AgencyId, NULL, @FromDateInitial)
--                   --           ORDER BY RowNumberDetail DESC
--                   --           UNION ALL
--
--                   SELECT *
--                   FROM dbo.[FN_GenerateBalanceElsCommissionsELS](@AgencyId, @FromDate, @ToDate)
--               ) AS Query;
--        INSERT INTO #TempTableElsFinal
--        (RowNumber, 
--         RowNumberDetail, 
--         AgencyId, 
--         Date, 
--         Description, 
--         Type, 
--         TypeId, 
--         TypeDetailId, 
--         Transactions, 
--         FeeEls, 
--         Credit, 
--         BalanceDetail, 
--         Balance
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
--               ABS(
--        (
--            SELECT SUM(t2.BalanceDetail)
--            FROM #TempTableElsFinal t2
--            WHERE T2.RowNumber <= T1.RowNumber
--        )) BalanceFinal
--        FROM #TempTableElsFinal t1
--        ORDER BY RowNumber ASC;
END;

GO