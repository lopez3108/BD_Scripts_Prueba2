SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:11-10-2023
--CAMBIOS EN 5424, Refactoring reporte de tax commissions

-- =============================================
-- Author:      JF
-- Create date: 27/06/2024 11:40 a. m.
-- Database:    devtest
-- Description: task 5938   Descripción erronea para comissions cancellations
-- =============================================


CREATE FUNCTION [dbo].[fn_GenerateTaxCommissionsInitialReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,[Type] VARCHAR(30)
 ,CreationDate DATETIME
 ,[Description] VARCHAR(100)
 ,Transactions INT -- nueva columna - sergio
 ,Usd DECIMAL(18, 2) NULL
 ,Commission DECIMAL(18, 2) NULL
 ,CreditCommission DECIMAL(18, 2) NULL
 ,[Month] INT NULL
 ,[Year] INT NULL
 ,Balance DECIMAL(18, 2)
)


AS
BEGIN


  INSERT INTO @result
    SELECT
      2
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,COUNT(*) AS Transactions -- Calculo del numero de cheques
     ,SUM(t.Usd)
     ,SUM(t.Commission)
     ,NULL
     ,NULL
     ,NULL,
       0 + SUM(t.Commission) Balance
    FROM (SELECT
        'CLOSING CHECKS' AS Type
       ,CAST(dbo.ChecksEls.CreationDate AS DATE) AS CreationDate
       ,'TAX CHECKS' AS Description
       ,ISNULL(dbo.ChecksEls.Amount, 0) AS Usd
       ,ISNULL((dbo.ChecksEls.Amount * dbo.ChecksEls.Fee / 100), 0) AS Commission
      FROM dbo.ChecksEls
      INNER JOIN dbo.ProviderTypes
        ON dbo.ProviderTypes.ProviderTypeId = dbo.ChecksEls.ProviderTypeId
      WHERE dbo.ProviderTypes.Code = 'C04'
      AND dbo.ChecksEls.AgencyId = @AgencyId
      AND CAST(dbo.ChecksEls.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.ChecksEls.CreationDate AS DATE) <= CAST(@ToDate AS DATE)) t
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description;


  -- Commissions

  INSERT INTO @result
    SELECT
      3
     ,'COMMISSIONS'
     ,  dbo.[fn_GetNextDayPeriod](Year, Month)
--     ,CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE)
--    ,'COMM. '
    ,'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description
--     ,'COMMISSIONS '
     ,'-'AS Transactions -- No hay transacciones en este contexto
     ,NULL
     ,NULL
     ,Usd
     ,dbo.ProviderCommissionPayments.Month
     ,dbo.ProviderCommissionPayments.Year,
      0 - ISNULL(Usd ,0) Balance
    FROM dbo.ProviderCommissionPayments
    INNER JOIN dbo.Providers
      ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE dbo.ProviderTypes.Code = 'C04'
    AND dbo.ProviderCommissionPayments.AgencyId = @AgencyId
--    AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--    AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
 AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)


  RETURN;
END;
GO