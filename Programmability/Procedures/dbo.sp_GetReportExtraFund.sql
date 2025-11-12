SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:18-10-2023
--CAMBIOS EN 5418, Refactoring reporte de extra fund
CREATE PROCEDURE [dbo].[sp_GetReportExtraFund]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
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
  SET @BalanceDetail = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2))) FROM dbo.FN_GenerateExtraFundReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1),
          [Index]       INT,
          [Type]        VARCHAR(30),
          CreationDate  DATETIME,
          [Description] VARCHAR(100),
          Debit         DECIMAL(18, 2) NULL,
          Credit        DECIMAL(18, 2) NULL,
         BalanceDetail DECIMAL(18, 2)

  )


  INSERT INTO #Temp
    SELECT
      0 [Index]
        ,'INITIAL BALANCE' Type
        ,CAST(@initialBalanceFinalDate AS Date) CreationDate
     ,'INITIAL BALANCE' Description
     ,0 Debit
     ,0 Credit
     ,@BalanceDetail BalanceDetail

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateExtraFundReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY CreationDate,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID     AND (T2.BalanceDetail > 0
      OR T2.BalanceDetail < 0))
    BalanceFinal
  FROM #Temp T1
--  WHERE (T1.BalanceDetail > 0
--  OR T1.BalanceDetail < 0)
     ORDER BY T1.CreationDate, T1.ID ASC;
  DROP TABLE #Temp
END






--     BEGIN
--         IF(@FromDate IS NULL)
--             BEGIN
--                 SET @FromDate = DATEADD(day, -10, @Date);
--                 SET @ToDate = @Date;
--         END;
--           DECLARE @initialBalanceFinalDate DATETIME
--  SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
--         CREATE TABLE #Temp
--         ([Index]       INT,
--          [Type]        VARCHAR(30),
--          CreationDate  DATETIME,
--          [Description] VARCHAR(100),
--          Debit         DECIMAL(18, 2) NULL,
--          Credit        DECIMAL(18, 2) NULL
--         );
--
--        -- Initial cash balance
--         INSERT INTO #Temp
--                SELECT 1,
--                       'INITIAL BALANCE',
--                       CAST(@initialBalanceFinalDate AS DATE),
--                       'INITIAL BALANCE',
--                       dbo.fn_CalculateExtraFundInitialBalance(@AgencyId, @initialBalanceFinalDate),
--                       NULL;
--					          
--
--        -- Cashiers from Admin
--
--         INSERT INTO #Temp
--                SELECT 2,
--                       t.Type,
--                       t.CreationDate,
--                       t.Description,
--                       SUM(t.Usd),--Debit
--					   NULL --Credit
--                       
--                FROM
--                (
--                    SELECT 'CASHIER FROM ADMIN' AS Type,
--                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
--                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
--                           'CLOSING DAILY' AS Description
--                    FROM dbo.ExtraFund
--                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
--                         INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
--                    WHERE CashAdmin = 0
--                          AND IsCashier = 0
--                          AND dbo.ExtraFund.AgencyId = @AgencyId
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
--
--						 -- Admin to cashiers
--
--         INSERT INTO #Temp
--                SELECT 3,
--                       t.Type,
--                       t.CreationDate,
--                       t.Description,
--                       NULL, --Debit
--                       SUM(t.Usd) --Credit
--                FROM
--                (
--                    SELECT 'ADMIN TO CASHIER' AS Type,
--                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
--                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
--                           'CLOSING DAILY' AS Description
--                    FROM dbo.ExtraFund
--                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
--                         INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
--                    WHERE CashAdmin = 0
--                          AND IsCashier = 0
--                          AND dbo.ExtraFund.AgencyId = @AgencyId
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
--
--         -- Cashiers from Cashiers
--
--         INSERT INTO #Temp
--                SELECT 4,
--                       t.Type,
--                       t.CreationDate,
--                       t.Description,
--                       SUM(t.Usd),--Debit
--                       NULL--Credit
--                FROM
--                (
--                    SELECT 'CASHIER FROM CASHIER' AS Type,
--                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
--                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
--                           'CLOSING DAILY' AS Description
--                    FROM dbo.Users AS Users_1
--                         INNER JOIN dbo.ExtraFund ON Users_1.UserId = dbo.ExtraFund.AssignedTo
--                         INNER JOIN Users U ON U.UserId = ExtraFund.AssignedTo
--                         LEFT JOIN Cashiers c ON U.UserId = c.UserId
--                    WHERE IsCashier = 1
--                          AND dbo.ExtraFund.AgencyId = @AgencyId
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
-- -- Cashiers to Cashiers
--
--         INSERT INTO #Temp
--                SELECT 5,
--                       t.Type,
--                       t.CreationDate,
--                       t.Description,
--                       NULL,--Debit
--                       SUM(t.Usd)--Credit
--                FROM
--                (
--                    SELECT 'CASHIER TO CASHIER' AS Type,
--                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
--                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
--                           'CLOSING DAILY' AS Description
--                    FROM dbo.ExtraFund
--                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
--                         INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
--                    WHERE IsCashier = 1
--                          AND dbo.ExtraFund.AgencyId = @AgencyId
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
--						         
--						 -- ADMIN FROM CASHIER
--         INSERT INTO #Temp
--                SELECT 6,
--                       t.Type,
--                       t.CreationDate,
--                       t.Description,
--                       SUM(t.Usd),--Debit
--                       NULL--Credit
--                FROM
--                (
--                    SELECT 'ADMIN FROM CASHIER' AS Type,
--                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
--                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
--                           'CLOSING DAILY' AS Description
--                    FROM dbo.ExtraFund
--                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
--                         LEFT JOIN Cashiers c ON Users.UserId = c.UserId
--                    WHERE CashAdmin = 1
--                          AND dbo.ExtraFund.CashAdmin = 1
--                          AND dbo.ExtraFund.AgencyId = @AgencyId
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
--
---- Cashiers TO ADMIN
--
--         INSERT INTO #Temp
--                SELECT 7,
--                       t.Type,
--                       t.CreationDate,
--                       t.Description,
--                       NULL,--Debit
--                       SUM(t.Usd) --Credit
--                FROM
--                (
--                    SELECT 'CASHIER TO ADMIN' AS Type,
--                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
--                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
--                           'CLOSING DAILY' AS Description
--                    FROM dbo.ExtraFund
--                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
--                         LEFT JOIN Cashiers c ON Users.UserId = c.UserId
--                    WHERE CashAdmin = 1
--                          AND dbo.ExtraFund.AgencyId = @AgencyId
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--                ) t
--                GROUP BY t.CreationDate,
--                         t.Type,
--                         t.Description;
--         SELECT *
--         FROM #Temp
--         ORDER BY CreationDate,
--                  [Index];
--         DROP TABLE #Temp;
--     END;




GO