SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/02-09-2025 Task 6738 En este reporte la información debe salir en bloque, es decir que está ordenado por fecha, luego la distribución  y finalmente el daily remaining.

CREATE FUNCTION [dbo].[FN_GetReportMoneyDistribution]
(
    @AgencyId  INT,
    @FromDate  DATE = NULL,
    @ToDate    DATE = NULL
)
RETURNS TABLE
AS
RETURN
WITH
-- 1) Filtrado sargable y columnas necesarias
FilteredDaily AS (
    SELECT DISTINCT
        d.AgencyId,
        d.DailyId,
        d.CreationDate,
        ISNULL(d.Cash, 0)             AS Cash,
        ISNULL(d.ClosedByCashAdmin,0) AS ClosedByCashAdmin,
        ISNULL(d.CashAdmin, 0)        AS CashAdmin
    FROM dbo.Daily AS d INNER JOIN DailyDistribution dd ON d.DailyId = dd.DailyId AND dd.Usd > 0 
    WHERE d.AgencyId = @AgencyId AND (d.Cash > 0  OR d.CashAdmin > 0)
      AND (@FromDate IS NULL OR d.CreationDate >= @FromDate)
      AND (@ToDate   IS NULL OR d.CreationDate < DATEADD(DAY, 1, @ToDate))
),

-- 2) Distribución por DailyId (USD) – MISMO criterio que la función detalle
Dist AS (
    SELECT
        dd.DailyId,
        SUM(CONVERT(DECIMAL(19,4), dd.Usd)) AS DistUsd
    FROM dbo.DailyDistribution AS dd
    INNER JOIN FilteredDaily AS fd
        ON fd.DailyId = dd.DailyId
    WHERE dd.Usd > 0
    GROUP BY dd.DailyId
),

-- 3) CashTotal por día con tu condición CASE (incluye DistUsd solo si ClosedByCashAdmin>0)
AggDaily AS (
    SELECT
        fd.AgencyId,
        CONVERT(date, fd.CreationDate) AS [Date],
        CAST(SUM(
            CASE
                WHEN fd.ClosedByCashAdmin > 0
                    THEN CONVERT(DECIMAL(19,4), fd.CashAdmin)
                         + ISNULL(CONVERT(DECIMAL(19,4), ds.DistUsd), 0)
                ELSE CONVERT(DECIMAL(19,4), fd.Cash)
            END
        ) AS DECIMAL(19,4)) AS CashTotal
    FROM FilteredDaily AS fd
    LEFT JOIN Dist       AS ds ON ds.DailyId = fd.DailyId
    GROUP BY fd.AgencyId, CONVERT(date, fd.CreationDate)
),

-- 4) UsdTotal por día (solo dd.Usd > 0)
AggDD AS (
    SELECT
        fd.AgencyId,
        CONVERT(date, fd.CreationDate) AS [Date],
        CAST(SUM(CONVERT(DECIMAL(19,4), dd.Usd)) AS DECIMAL(19,4)) AS UsdTotal
    FROM dbo.DailyDistribution AS dd
    INNER JOIN FilteredDaily AS fd
        ON fd.DailyId = dd.DailyId
    WHERE dd.Usd > 0
    GROUP BY fd.AgencyId, CONVERT(date, fd.CreationDate)
),

-- 5) Combina días (NO perder días sin distribución)
Combined AS (
    SELECT
        d.AgencyId,
        d.[Date],
        d.CashTotal,
        ISNULL(dd.UsdTotal, 0) AS UsdTotal
    FROM AggDaily AS d
    LEFT JOIN AggDD   AS dd
        ON dd.AgencyId = d.AgencyId
       AND dd.[Date]   = d.[Date]
)

-- 6) Proyección final (AGRUPADA por fecha, tipo y descripción - textos intactos)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            [Date] ASC,
            TypeOrder ASC,      -- << clave para el orden: 1=Closing Daily, 2=Money Distribution, 3=Closing Daily Remaining
            TypeId ASC,
            [Description] ASC
    ) AS RowNumber,
    AgencyId,
    CAST([Date] AS DATETIME) AS [Date],
    [Type],
    TypeId,
    [Description],
    CAST(Debit         AS DECIMAL(18,2)) AS Debit,
    CAST(Credit        AS DECIMAL(18,2)) AS Credit,
    CAST(BalanceDetail AS DECIMAL(18,2)) AS BalanceDetail
FROM (
    -- CLOSING DAILY (usa CashTotal)  → primero
    SELECT
        AgencyId,
        [Date],
        CAST('CLOSING DAILY' AS VARCHAR(1000)) AS [Type],
        1 AS TypeId,                                -- (no cambiamos tu TypeId)
        CAST('CLOSING DAILY' AS VARCHAR(1000)) AS [Description],
        CashTotal AS Debit,
        CAST(0 AS DECIMAL(19,4)) AS Credit,
        CashTotal AS BalanceDetail,
        1 AS TypeOrder                               -- << primero
    FROM Combined

    UNION ALL

    -- MONEY DISTRIBUTION (usa UsdTotal) → segundo
    SELECT 
        AgencyId,
        [Date],
        CAST('MONEY DISTRIBUTION' AS VARCHAR(1000)) AS [Type],
        1 AS TypeId,                                -- (respetando tu valor actual)
        CAST('MONEY DISTRIBUTION' AS VARCHAR(1000)) AS [Description],
        CAST(0 AS DECIMAL(19,4)) AS Debit,
        UsdTotal AS Credit,
        -UsdTotal AS BalanceDetail,
        2 AS TypeOrder                               -- << segundo
    FROM Combined

    UNION ALL

    -- CLOSING DAILY REMAINING = CashTotal - UsdTotal → tercero
    SELECT
        AgencyId,
        [Date],
        CAST('MONEY DISTRIBUTION' AS VARCHAR(1000)) AS [Type],  -- respetando tu Type actual
        2 AS TypeId,                                            -- y tu TypeId actual
        CAST('CLOSING DAILY REMAINING' AS VARCHAR(1000)) AS [Description],
        CAST(0 AS DECIMAL(19,4)) AS Debit,
        (CashTotal - UsdTotal) AS Credit,
        -(CashTotal - UsdTotal) AS BalanceDetail,
        3 AS TypeOrder                               -- << tercero
    FROM Combined WHERE (CashTotal - UsdTotal) > 0
) AS X;



GO