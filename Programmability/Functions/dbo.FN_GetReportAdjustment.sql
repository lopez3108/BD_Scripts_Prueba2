SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: Felipe
--LASTUPDATEDON:26-10-2023

CREATE FUNCTION [dbo].[FN_GetReportAdjustment] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL)
RETURNS @result TABLE (
  RowNumber INT
 ,PaymentAdjustmentId INT
 ,AgencyFromId INT
 ,AgencyToId INT
 ,Date DATE
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,Description VARCHAR(1000)
 ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,ProviderId INT
 ,BalanceDetail DECIMAL(18, 2)
)


AS
BEGIN

  INSERT INTO @result
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY Query.PaymentAdjustmentId, CAST(Query.Date AS Date) ASC, Query.AgencyFromId ASC, Query.AgencyToId ASC, Query.TypeId ASC, Query.ProviderId ASC) RowNumber
       ,*
      FROM (SELECT
          p.PaymentAdjustmentId
         ,p.AgencyFromId
         ,p.AgencyToId
         ,CAST(p.Date AS DATETIME) AS Date
         ,'ADJUSTMENT' AS Type
         ,0 AS TypeId
         ,pp.Name + ' - ' + m.Number AS Description
         ,
          --pp.Name+' - '+m.Number + ' DEBIT' AS Description,
          p.USD AS Debit
         ,0 AS Credit
         ,p.ProviderId
         ,
          --       SUM(p.USD) AS BalanceDetail
          0 + ISNULL(SUM(p.USD), 0) AS BalanceDetail
        FROM PaymentAdjustment p
        INNER JOIN MoneyTransferxAgencyNumbers m
          ON m.ProviderId = p.ProviderId
          AND m.AgencyId = p.AgencyFromId
        INNER JOIN Providers pp
          ON pp.ProviderId = p.ProviderId
        WHERE (p.AgencyFromId = @AgencyId
        OR p.AgencyToId = @AgencyId
        OR @AgencyId IS NULL)
        AND CAST(p.Date AS Date) >= CAST(@FromDate AS Date)
        AND CAST(p.Date AS Date) <= CAST(@ToDate AS Date)
        AND p.DeletedBy IS NULL
        AND p.DeletedOn IS NULL
        GROUP BY p.PaymentAdjustmentId
                ,CAST(p.Date AS DATETIME)
                ,p.AgencyFromId
                ,p.AgencyToId
                ,p.USD
                ,p.ProviderId
                ,pp.Name
                ,m.Number
        UNION ALL
        SELECT
          p.PaymentAdjustmentId
         ,p.AgencyFromId
         ,p.AgencyToId
         ,CAST(p.Date AS DATETIME) AS Date
         ,'ADJUSTMENT' AS Type
         ,1 AS TypeId
         ,pp.Name + ' - ' + m.Number AS Description
         ,
          --pp.Name+' - '+m.Number + ' CREDIT' AS Description,
          0 AS Debit
         ,p.USD AS Credit
         ,p.ProviderId
         ,
          --       -SUM(p.USD) AS BalanceDetail
          0 - ISNULL(SUM(p.USD), 0) AS BalanceDetail
        FROM PaymentAdjustment p
        INNER JOIN MoneyTransferxAgencyNumbers m
          ON m.ProviderId = p.ProviderId
          AND m.AgencyId = p.AgencyToId
        INNER JOIN Providers pp
          ON pp.ProviderId = p.ProviderId
        WHERE (p.AgencyFromId = @AgencyId
        OR p.AgencyToId = @AgencyId
        OR @AgencyId IS NULL)
        AND CAST(p.Date AS Date) >= CAST(@FromDate AS Date)
        AND CAST(p.Date AS Date) <= CAST(@ToDate AS Date)
        AND p.DeletedBy IS NULL
        AND p.DeletedOn IS NULL
        GROUP BY p.PaymentAdjustmentId
                ,CAST(p.Date AS DATETIME)
                ,p.AgencyFromId
                ,p.AgencyToId
                ,p.USD
                ,p.ProviderId
                ,pp.Name
                ,m.Number

--        UNION ALL
--        SELECT
--          0 PaymentAdjustmentId
--         ,t.AgencyFromId
--         ,0 AgencyToId
--         ,t.Date
--         ,t.Type
--         ,2 AS TypeId
--         ,t.Description
--         ,SUM(t.Usd) AS Debit
--         ,0 AS Credit
--         ,t.ProviderId
--         ,SUM(t.Usd) AS BalanceDetail
--        FROM (SELECT
--            pc.AgencyId AS AgencyFromId
--           ,CAST(pc.AdjustmentDate AS Date) AS Date
--           ,'ADJUSTMENT COMMISSION' AS Type
--           ,REPLACE(REPLACE(Providers.Name, CHAR(13), ''), CHAR(10), '') + ' ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) AS Description
--           ,pc.Usd
--           ,pc.ProviderId
--      FROM dbo.ProviderCommissionPayments pc
--          INNER JOIN dbo.ProviderCommissionPaymentTypes rpm
--            ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId
--          INNER JOIN Providers
--            ON Providers.ProviderId = pc.ProviderId
--          WHERE rpm.Code = 'CODE04'
--          AND ((@FromDate IS NULL)
--          OR (CAST(CreationDate AS Date) >= CAST(@FromDate AS Date)))
--          AND ((@ToDate IS NULL)
--          OR (CAST(CreationDate AS Date) <= CAST(@ToDate AS Date)))
--
--          AND AgencyId = @AgencyId
--          AND pc.Usd > 0) t
--        GROUP BY t.Date
--                ,t.Type
--                ,t.Description
--                ,t.ProviderId
--                ,t.AgencyFromId
                
                ) AS Query) AS QueryFinal;




  RETURN;
END;
GO