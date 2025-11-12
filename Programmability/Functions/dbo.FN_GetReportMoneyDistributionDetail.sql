SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- LASTUPDATEDBY: Refactor
-- LASTUPDATEDON: 2025-09-01

--Last update by JT/02-09-2025 Task 6738 En este reporte la información debe salir en bloque, es decir que está ordenado por fecha, luego el cajero, luego la distribución de ese cajero y finalmente el daily remaining para ese cajero.
--Last update by JT/02-10-2025 Task 6753 En el money distribution debe mostrar el código del provider al que se envió el dinero, anterior mente estaba mostrando el provider del que salió el dinero 

CREATE FUNCTION [dbo].[FN_GetReportMoneyDistributionDetail] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
  RowNumber INT
 ,AgencyId INT
 ,[Date] DATETIME
 ,[Type] VARCHAR(1000)
 ,TypeId INT
 ,[Description] VARCHAR(1000)
 ,PackageNumber VARCHAR(1000)
 ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
)
AS
BEGIN
  ;
  WITH
  -- 1) Filtrado sargable + datos necesarios (incluye usuario/cajero)
  FilteredDaily
  AS
  (SELECT DISTINCT
      d.AgencyId
     ,d.DailyId
     ,d.CreationDate
     ,ISNULL(d.Cash, 0) AS Cash
     ,ISNULL(d.ClosedByCashAdmin, 0) AS ClosedByCashAdmin
     ,ISNULL(d.CashAdmin, 0) AS CashAdmin
     ,u.[Name] AS UserName
     ,u.UserId AS UserId
    FROM dbo.Daily AS d INNER JOIN DailyDistribution dd ON d.DailyId = dd.DailyId AND dd.Usd > 0 
    INNER JOIN dbo.Cashiers AS c
      ON c.CashierId = d.CashierId
    INNER JOIN dbo.Users AS u
      ON u.UserId = c.UserId
    WHERE d.AgencyId = @AgencyId AND (d.Cash > 0  OR d.CashAdmin > 0)
    AND (@FromDate IS NULL
    OR d.CreationDate >= @FromDate)
    AND (@ToDate IS NULL
    OR d.CreationDate < DATEADD(DAY, 1, @ToDate))),
  -- 2) Distribución por DailyId (USD)
  Dist
  AS
  (SELECT
      dd.DailyId
     ,SUM(CONVERT(DECIMAL(19, 4), dd.USD)) AS DistUsd
    FROM dbo.DailyDistribution AS dd
    INNER JOIN FilteredDaily AS fd
      ON fd.DailyId = dd.DailyId  WHERE dd.Usd > 0 
    GROUP BY dd.DailyId),
  -- 3) Expresión de "Cash" por cada Daily (aplica el CASE de admin)
  DailyWithExpr
  AS
  (SELECT
      fd.AgencyId
     ,CONVERT(DATE, fd.CreationDate) AS [Date]
     ,fd.DailyId
     ,fd.UserName
     ,fd.UserId
     ,CAST(
      CASE
        WHEN fd.ClosedByCashAdmin > 0 THEN CONVERT(DECIMAL(19, 4), fd.CashAdmin)
          + ISNULL(CONVERT(DECIMAL(19, 4), ds.DistUsd), 0)
        ELSE CONVERT(DECIMAL(19, 4), fd.Cash)
      END
      AS DECIMAL(19, 4)) AS CashExpr
    FROM FilteredDaily AS fd
    LEFT JOIN Dist AS ds
      ON ds.DailyId = fd.DailyId),
  -- 4) Totales por día y usuario (para el REMAINING)
  AggRemaining
  AS
  (SELECT
      dwe.AgencyId
     ,dwe.[Date]
     ,dwe.UserName
     ,CAST(SUM(dwe.CashExpr) AS DECIMAL(19, 4)) AS CashExprTotal
     ,CAST(SUM(ISNULL(ds.DistUsd, 0)) AS DECIMAL(19, 4)) AS UsdTotal
    FROM DailyWithExpr AS dwe
    LEFT JOIN Dist AS ds
      ON ds.DailyId = dwe.DailyId
    GROUP BY dwe.AgencyId
            ,dwe.[Date]
            ,dwe.UserName
            ,dwe.UserId),
  -- 5) Detalle: CLOSING DAILY (por cada Daily, con usuario)
  ClosingDailyRows
  AS
  (SELECT DISTINCT
      AgencyId
     ,CAST([Date] AS DATETIME) AS [Date]
     ,CAST('CLOSING DAILY' AS VARCHAR(1000)) AS [Type]
     ,1 AS TypeId
     ,UserName AS [Description]
     ,CAST('' AS VARCHAR(1000)) AS PackageNumber
     ,CashExpr AS Debit
     ,CAST(0 AS DECIMAL(19, 4)) AS Credit
     ,CashExpr AS BalanceDetail
     ,UserName AS SortUserName
     ,1 AS TypeOrder
    FROM DailyWithExpr),
  -- 6) Detalle: MONEY DISTRIBUTION (por cada movimiento, asociado al usuario del Daily)
  MoneyDistributionRows
  AS
  (SELECT DISTINCT
      d.AgencyId
     ,CAST(CONVERT(Date, d.CreationDate) AS DATETIME) AS [Date]
     ,CAST('MONEY DISTRIBUTION' AS VARCHAR(1000)) AS [Type]
     ,CASE
        WHEN dd.ProviderId IS NOT NULL THEN 2
        WHEN dd.BankAccountId IS NOT NULL THEN 3
      END AS TypeId
     ,CASE
        WHEN dd.ProviderId IS NOT NULL THEN p.[Name] + ' ' + ISNULL(dd.Code, '')--6753
        WHEN dd.BankAccountId IS NOT NULL THEN 'BANK - ' + RIGHT(Ba.AccountNumber, 4) + ' (' + B.[Name] + ')'
      END AS [Description]
     ,dd.PackageNumber
     ,CAST(0 AS DECIMAL(19, 4)) AS Debit
     ,CONVERT(DECIMAL(19, 4), dd.Usd) AS Credit
     ,-CONVERT(DECIMAL(19, 4), dd.Usd) AS BalanceDetail
     ,fd.UserName AS SortUserName
     ,   -- <== clave de orden por usuario
      2 AS TypeOrder
    FROM dbo.DailyDistribution AS dd
    INNER JOIN dbo.Daily AS d
      ON d.DailyId = dd.DailyId
    INNER JOIN FilteredDaily fd
      ON fd.DailyId = d.DailyId  -- trae el UserName del Daily
    LEFT JOIN dbo.Providers AS p
      ON p.ProviderId = dd.ProviderId
    LEFT JOIN dbo.MoneyTransferxAgencyNumbers AS m
      ON m.ProviderId = dd.ProviderId
      AND m.AgencyId = d.AgencyId
    LEFT JOIN dbo.BankAccounts AS Ba
      ON Ba.BankAccountId = dd.BankAccountId
    LEFT JOIN dbo.Bank AS B
      ON B.BankId = Ba.BankId
    WHERE d.AgencyId = @AgencyId
    AND  dd.Usd > 0  AND (@FromDate IS NULL
    OR d.CreationDate >= @FromDate)
    AND (@ToDate IS NULL
    OR d.CreationDate < DATEADD(DAY, 1, @ToDate))),
  -- 7) Agregado por día y usuario: CLOSING DAILY REMAINING
  RemainingRows
  AS
  (SELECT
      AgencyId
     ,CAST([Date] AS DATETIME) AS [Date]
     ,CAST('CLOSING DAILY REMAINING' AS VARCHAR(1000)) AS [Type]
     ,4 AS TypeId
     ,UserName AS [Description]
     , -- mostramos el usuario
      CAST('' AS VARCHAR(1000)) AS PackageNumber
     ,CAST(0 AS DECIMAL(19, 4)) AS Debit
     ,(CashExprTotal - UsdTotal) AS Credit
     ,-(CashExprTotal - UsdTotal) AS BalanceDetail
     ,UserName AS SortUserName
     ,3 AS TypeOrder
    FROM AggRemaining)

  INSERT INTO @result (RowNumber, AgencyId, [Date], [Type], TypeId, [Description], PackageNumber, Debit, Credit, BalanceDetail)
    SELECT
      ROW_NUMBER() OVER (
      ORDER BY
      [Date] ASC,
      SortUserName ASC,
      TypeOrder ASC,
      TypeId ASC,
      [Description] ASC
      ) AS RowNumber
     ,AgencyId
     ,[Date]
     ,[Type]
     ,TypeId
     ,[Description]
     ,PackageNumber
     ,CAST(Debit AS DECIMAL(18, 2)) AS Debit
     ,CAST(Credit AS DECIMAL(18, 2)) AS Credit
     ,CAST(BalanceDetail AS DECIMAL(18, 2)) AS BalanceDetail
    FROM (SELECT
        AgencyId
       ,[Date]
       ,[Type]
       ,TypeId
       ,[Description]
       ,PackageNumber
       ,Debit
       ,Credit
       ,BalanceDetail
       ,SortUserName
       ,TypeOrder
      FROM ClosingDailyRows
      UNION ALL
      SELECT
        AgencyId
       ,[Date]
       ,[Type]
       ,TypeId
       ,[Description]
       ,PackageNumber
       ,Debit
       ,Credit
       ,BalanceDetail
       ,SortUserName
       ,TypeOrder
      FROM MoneyDistributionRows
      UNION ALL
      SELECT
        AgencyId
       ,[Date]
       ,[Type]
       ,TypeId
       ,[Description]
       ,PackageNumber
       ,Debit
       ,Credit
       ,BalanceDetail
       ,SortUserName
       ,TypeOrder
      FROM RemainingRows) AS X;

  RETURN;
END




GO