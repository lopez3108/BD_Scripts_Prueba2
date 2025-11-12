SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de others detail

-- =============================================
-- Author:      JF
-- Create date: 23/06/2024 11:29 p. m.
-- Database:    devtest
-- Description: task: 5896  Ajustes reporte OTHER SERVICES
-- =============================================


CREATE         PROCEDURE [dbo].[sp_GetReportOthers]
(@AgencyId   INT,
 @FromDate   DATETIME = NULL,
 @ToDate     DATETIME = NULL,
 @Date       DATETIME
-- @OthersIds VARCHAR(100) = NULL
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
SET @FromDate = DATEADD(DAY, -10, @Date);
SET @ToDate = @Date;
         END;
       DECLARE @initialBalanceFinalDate DATETIME
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
 DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = ISNULL((SELECT
      SUM(CAST(Balance AS DECIMAL(18,2)))
    FROM [dbo].fn_GenerateOthersDetailsReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)


CREATE TABLE #Temp (
      [ID] INT IDENTITY (1, 1),
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
); 


-- Initial cash balance
INSERT INTO #Temp
	SELECT
		1  [Index]
	   ,'INITIAL BALANCE'
	   ,CAST(@initialBalanceFinalDate AS DATE) CreationDate
	   ,'INITIAL BALANCE'
     ,'-' Transactions
     ,NULL
--	   ,dbo.fn_CalculateOhersInitialBalance(@AgencyId, @initialBalanceFinalDate)
	   ,NULL
	   ,NULL
	   ,NULL
     ,@BalanceDetail Balance

 UNION ALL
    SELECT
      *
    FROM [dbo].fn_GenerateOthersDetailsReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY CreationDate,
    [Index];


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Balance AS DECIMAL(18,2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1

  ORDER BY CreationDate,
  [Index];
  DROP TABLE #Temp;



---- Daily
--
--INSERT INTO #Temp
--	SELECT
--		2
--	   ,t.Type
--	   ,t.CreationDate
--	   ,t.Description
--	   ,SUM(t.Usd)
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	FROM (SELECT
--			'DAILY' AS Type
--		   ,CAST(dbo.[OthersDetails].CreationDate AS DATE) AS CreationDate
--		   ,'CLOSING DAILY' AS Description
--		   ,ISNULL(dbo.OthersDetails.Usd, 0) AS Usd
--		FROM dbo.OthersDetails
--		INNER JOIN dbo.Users U ON U.UserId = OthersDetails.CreatedBy
--		WHERE dbo.OthersDetails.AgencyId = @AgencyId
--		AND CAST(dbo.OthersDetails.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--		AND CAST(dbo.OthersDetails.CreationDate AS DATE) <= CAST(@ToDate AS DATE)) t
--	GROUP BY t.CreationDate
--			,t.Type
--			,t.Description;
--
--
---- Commissions
--
--INSERT INTO #Temp
--	SELECT
--		3
--	   ,'COMMISSIONS'
--	   ,CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE)
--	   ,'COMMISSIONS '
--	   ,NULL
--	   ,Usd
--	   ,dbo.ProviderCommissionPayments.Month
--	   ,dbo.ProviderCommissionPayments.Year
--	FROM dbo.ProviderCommissionPayments
--	INNER JOIN dbo.Providers
--		ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
--	INNER JOIN dbo.ProviderTypes
--		ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--	WHERE dbo.ProviderTypes.Code = 'C07'
--	AND dbo.ProviderCommissionPayments.AgencyId = @AgencyId
--	AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--	AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--
--
--
--
--
--SELECT
--	*
--FROM #Temp
--ORDER BY CreationDate,
--[Index];
--DROP TABLE #Temp;
END;
GO