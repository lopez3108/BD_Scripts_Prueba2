SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de others detail

-- =============================================
-- Author:      JF
-- Create date: 28/06/2024 12:14 p. m.
-- Database:    [copiaSecure21-06-2024]
-- Description: task 5896  Ajustes reporte OTHER SERVICES
-- =============================================


CREATE   FUNCTION [dbo].[fn_GenerateOthersDetailsReport] (@AgencyId INT,
@FromDate DATETIME = NULL, @ToDate DATETIME = NULL)

RETURNS @result TABLE (
  [Index] INT
   ,[Type] VARCHAR(30)
   ,CreationDate DATETIME
   ,[Description] VARCHAR(100)
   ,Transactions INT
   ,Usd DECIMAL(18, 2) NULL
   ,Commission DECIMAL(18, 2) NULL
   ,[Month] INT NULL
   ,[Year] INT NULL,
   Balance DECIMAL(18,2)  null
)
AS
BEGIN

  INSERT INTO @result
   	SELECT
	3
	   ,t.Type
	   ,t.CreationDate
	   ,t.Description
     ,COUNT(t.CreationDate) AS Transactions
	   ,SUM(t.Usd)
	   ,NULL
	   ,NULL
	   ,NULL,
      SUM(t.Usd)
	FROM (SELECT
			'DAILY' AS Type
		   ,CAST(dbo.[OthersDetails].CreationDate AS DATE) AS CreationDate
		   ,'CLOSING DAILY' AS Description
		   ,ISNULL(dbo.OthersDetails.Usd, 0) AS Usd
		FROM dbo.OthersDetails
		INNER JOIN dbo.Users U ON U.UserId = OthersDetails.CreatedBy
		WHERE dbo.OthersDetails.AgencyId = @AgencyId
--    (OthersDetails.OtherServiceId IN
--         (
--             SELECT item
--             FROM dbo.FN_ListToTableInt(@OthersIds)
--         ) OR @OthersIds IS NULL )
		AND CAST(dbo.OthersDetails.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
		AND CAST(dbo.OthersDetails.CreationDate AS DATE) <= CAST(@ToDate AS DATE)) t
	GROUP BY t.CreationDate
			,t.Type
			,t.Description;


-- Commissions

INSERT INTO @result
	SELECT
		2
	   ,'COMMISSION'
     ,dbo.[fn_GetNextDayPeriod](Year, Month)
--	   ,CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE)
     ,'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description

--	   ,'COMMISSIONS '
     ,1 AS Transactions
	   ,NULL
	   ,Usd
	   ,dbo.ProviderCommissionPayments.Month
	   ,dbo.ProviderCommissionPayments.Year,
    0 - Usd
	FROM dbo.ProviderCommissionPayments
	INNER JOIN dbo.Providers
		ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
	INNER JOIN dbo.ProviderTypes
		ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
	WHERE dbo.ProviderTypes.Code = 'C07'
	AND dbo.ProviderCommissionPayments.AgencyId = @AgencyId
   AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
--	AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--	AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)




  RETURN

END
GO