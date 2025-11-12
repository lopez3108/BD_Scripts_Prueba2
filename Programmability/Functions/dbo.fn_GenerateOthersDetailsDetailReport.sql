SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de others detail

-- =============================================
-- Author:      JF
-- Create date: 24/06/2024 12:01 a. m.
-- Database:    devtest
-- Description: task: 5896  Ajustes reporte OTHER SERVICES
-- =============================================


CREATE         FUNCTION [dbo].[fn_GenerateOthersDetailsDetailReport] (@AgencyId INT,
@FromDate DATETIME = NULL, @ToDate DATETIME = NULL)

RETURNS @result TABLE (
  [Index] INT
 ,Date DATETIME
 ,Type VARCHAR(1000)
 ,Description VARCHAR(1000)
 ,Transactions INT
 ,NameEmployee VARCHAR(80)
 ,TypeId INT
 ,Usd DECIMAL(18, 2)
 ,Commission DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS
BEGIN



  INSERT INTO @result
    SELECT
      2 [Index]
     ,CAST(O.CreationDate AS Date) AS Date
     ,'DAILY' AS Type
     ,OS.Name AS Description
     ,COUNT(O.CreationDate) AS Transactions
     ,U.Name NameEmployee
     ,2 TypeId
     ,SUM(O.Usd) AS Usd
     ,0 Commission
     ,SUM(O.Usd) AS Balance
    FROM dbo.OthersDetails O
    INNER JOIN OthersServices OS
      ON O.OtherServiceId = OS.OtherId
    INNER JOIN dbo.Users U
      ON U.UserId = O.CreatedBy

    WHERE O.AgencyId = @AgencyId 
--    (O.OtherServiceId IN
--         (
--             SELECT item
--             FROM dbo.FN_ListToTableInt(@OthersIds)
--         ) OR @OthersIds IS NULL )
    AND (CAST(O.CreationDate AS Date) >= CAST(@FromDate AS Date)
    OR @FromDate IS NULL)
    AND (CAST(O.CreationDate AS Date) <= CAST(@ToDate AS Date)
    OR @ToDate IS NULL)
    GROUP BY CAST(O.CreationDate AS Date)
            ,OS.Name
            ,U.Name
            ,O.OtherServiceId


  INSERT INTO @result
    SELECT
      1 [Index]
--     ,CAST(dbo.ProviderCommissionPayments.CreationDate AS Date) AS Date
     ,dbo.[fn_GetNextDayPeriod](Year, Month)
     ,'COMMISSION' AS Type
--     ,'COMMISSION' AS Description
    ,'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description
     ,1 AS Transactions
     ,U.Name NameEmployee
     ,1 TypeId
     ,0 Usd
     ,SUM(dbo.ProviderCommissionPayments.Usd) AS Commission
     ,-(SUM(dbo.ProviderCommissionPayments.Usd)) AS Balance
    FROM dbo.ProviderCommissionPayments
    INNER JOIN dbo.Providers
      ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    INNER JOIN dbo.Users U
      ON U.UserId = ProviderCommissionPayments.CreatedBy
    WHERE dbo.ProviderTypes.Code = 'C07'
    AND dbo.ProviderCommissionPayments.AgencyId = @AgencyId
     AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
--    AND CAST(dbo.ProviderCommissionPayments.CreationDate AS Date) >= CAST(@FromDate AS Date)
--    AND CAST(dbo.ProviderCommissionPayments.CreationDate AS Date) <= CAST(@ToDate AS Date)

    GROUP BY CAST(dbo.ProviderCommissionPayments.CreationDate AS Date)
            ,U.Name,ProviderCommissionPayments.Month,ProviderCommissionPayments.Year








  RETURN

END
GO