SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/24-09-2025 task 6763 Bugs generales del proceso Fee due, ACH date y view contract
--Updated by jt/27-10-2025 task 6807 Add new columns, apartment number and status desposit, and new record for refunded moventments

CREATE PROCEDURE [dbo].[sp_GetPropertyDepositPaymentsByPeriod] @PropertiesId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@CreationDate DATETIME = NULL
AS
  SET NOCOUNT ON;
  BEGIN
    IF (@FromDate IS NULL)
    BEGIN
      SET @FromDate = DATEADD(DAY, -10, @CreationDate);
      SET @ToDate = @CreationDate;
    END;

    SELECT
      ContractId
     ,TypeIndex
     ,CAST(QUERY.FromDate AS DATE) FromDate
     ,CAST(QUERY.ToDate AS DATE) ToDate
     ,CAST(QUERY.CreationDate AS DATE) CreationDate
     ,CAST(QUERY.AchDate AS DATE) AchDate
     ,SUM(Usd) Usd
     ,Tenant
     ,StatusDeposit
     ,ApartmentNumber
    FROM (SELECT
        c.ContractId
       ,1 TypeIndex
       ,@FromDate FromDate
       ,@ToDate ToDate
       ,CAST(dfp.CreationDate AS DATE) CreationDate
       ,CAST(dfp.AchDate AS DATE) AchDate
       ,SUM(Usd) Usd
       ,T.Name Tenant
       ,'AVAILABLE' StatusDeposit
       ,A.Number ApartmentNumber
      FROM DepositFinancingPayments dfp
      INNER JOIN Contract c
        ON c.ContractId = dfp.ContractId
      INNER JOIN Apartments A
        ON c.ApartmentId = A.ApartmentsId
      INNER JOIN Properties p
        ON p.PropertiesId = A.PropertiesId
      INNER JOIN dbo.TenantsXcontracts AS TC
        ON c.ContractId = TC.ContractId
        AND TC.Principal = 1
      INNER JOIN dbo.Tenants AS T
        ON TC.TenantId = T.TenantId
      WHERE p.PropertiesId = @PropertiesId
      AND ((dfp.AchDate IS NOT NULL
      AND ((@FromDate IS NULL
      OR CAST(dfp.AchDate AS DATE) >= CAST(@FromDate AS DATE))
      AND (@ToDate IS NULL
      OR CAST(dfp.AchDate AS DATE) <= CAST(@ToDate AS DATE))))
      OR (dfp.AchDate IS NULL
      AND ((@FromDate IS NULL
      OR CAST(dfp.CreationDate AS DATE) >= CAST(@FromDate AS DATE))
      AND (@ToDate IS NULL
      OR CAST(dfp.CreationDate AS DATE) <= CAST(@ToDate AS DATE)))))
      GROUP BY c.ContractId
              ,CAST(dfp.CreationDate AS DATE)
              ,T.Name
              ,A.Number
              ,CAST(dfp.AchDate AS DATE)
     UNION ALL
SELECT
    c.ContractId,
    2 AS TypeIndex,
    @FromDate AS FromDate,
    @ToDate AS ToDate,
    c.RefundDate AS CreationDate,
    (
        SELECT TOP 1 
            CASE 
                WHEN dp.AchDate IS NOT NULL THEN dp.AchDate 
                ELSE dp.CreationDate 
            END
        FROM DepositFinancingPayments dp
        WHERE dp.ContractId = c.ContractId
        ORDER BY COALESCE(dp.AchDate, dp.CreationDate) DESC
    ) AS AchDate,
    -c.RefundUsd AS Usd,
    T.Name AS Tenant,
    CONCAT(
        'REFUNDED (',
        FORMAT(
            CASE 
                WHEN c.AchDate IS NOT NULL THEN c.AchDate 
                ELSE c.RefundDate 
            END,
            'MM-dd-yyyy'
        ),
        ')'
    ) AS StatusDeposit,
    A.Number AS ApartmentNumber
FROM Contract c
INNER JOIN Apartments A
    ON c.ApartmentId = A.ApartmentsId
INNER JOIN Properties p
    ON p.PropertiesId = A.PropertiesId
INNER JOIN dbo.TenantsXcontracts AS TC
    ON c.ContractId = TC.ContractId
    AND TC.Principal = 1
INNER JOIN dbo.Tenants AS T
    ON TC.TenantId = T.TenantId
WHERE 
    p.PropertiesId = @PropertiesId
    AND c.RefundDate IS NOT NULL
    AND (
        -- 1) RefundDate dentro del rango (c.RefundDate)
        CAST(c.RefundDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
        -- 2) O existe algún pago para el contrato cuya fecha efectiva esté dentro del rango
        OR EXISTS (
            SELECT 1
            FROM DepositFinancingPayments dp2
            WHERE dp2.ContractId = c.ContractId
              AND CAST(COALESCE(dp2.AchDate, dp2.CreationDate) AS DATE) 
                  BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
        )
    )
) AS QUERY
    --      ORDER BY  COALESCE(QUERY.AchDate, QUERY.CreationDate) ASC,  QUERY.ContractId, TypeIndex
    GROUP BY QUERY.ContractId
            ,CAST(QUERY.FromDate AS DATE)
            ,CAST(QUERY.ToDate AS DATE)
            ,QUERY.Tenant
            ,QUERY.ApartmentNumber
            ,CAST(QUERY.AchDate AS DATE)
            ,CAST(QUERY.CreationDate AS DATE)
            ,StatusDeposit
            ,QUERY.TypeIndex
    ORDER BY QUERY.ApartmentNumber,            -- Primero por apartamento (Campin-01, Campin-02, etc.)
    QUERY.Tenant,                     -- Luego por inquilino
    QUERY.ContractId,                 -- Luego por contrato
    CASE
      WHEN QUERY.TypeIndex = 2 THEN 1
      ELSE 0
    END,  -- Los REFUNDED al final
    COALESCE(CAST(QUERY.AchDate AS DATE), CAST(QUERY.CreationDate AS DATE)) ASC;  -- Por fecha
  END;



GO