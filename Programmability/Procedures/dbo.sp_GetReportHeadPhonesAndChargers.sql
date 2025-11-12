SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportHeadPhonesAndChargers]
(@AgencyId   INT,
 @FromDate   DATETIME = NULL,
 @ToDate     DATETIME = NULL,
 @Date       DATETIME
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;

         CREATE TABLE #Temp
         ([Index]       INT,
          [Type]        VARCHAR(30),
          CreationDate  DATETIME,
          [Description] VARCHAR(100),
          Usd           DECIMAL(18, 2),
		  Cost           DECIMAL(18, 2) NULL,
		  CreditCommission           DECIMAL(18, 2) NULL,
		  [Month] INT NULL,
		  [Year] INT NULL
         );


-- Initial cash balance
         INSERT INTO #Temp
                SELECT 1,
                       'INITIAL BALANCE',
                       CAST(@FromDate AS DATE),
                       'INITIAL BALANCE',
                       dbo.fn_CalculateHeadPhonesAndChargersInitialBalance(@AgencyId, @FromDate),
					   NULL,
					   NULL,
					   NULL,
					   NULL


-- Daily headphones

         INSERT INTO #Temp
                SELECT 2,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       SUM(t.Usd) AS Usd,
					   SUM(t.Cost) AS Cost,
					   NULL,
					   NULL,
					   NULL
                FROM
                (
                    SELECT 'HEADPHONES' AS Type,
                           CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate,
                           'CLOSING DAILY' AS Description,
                           ISNULL(dbo.HeadphonesAndChargers.HeadphonesUsd, 0) AS Usd,
						   ISNULL(dbo.HeadphonesAndChargers.CostHeadPhones, 0) * ISNULL(dbo.HeadphonesAndChargers.HeadphonesQuantity, 0) AS Cost
						   FROM            dbo.Daily  INNER JOIN
dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId INNER JOIN
                         dbo.HeadphonesAndChargers ON dbo.Daily.AgencyId = dbo.HeadphonesAndChargers.AgencyId
						 AND CAST(HeadphonesAndChargers.CreationDate as date) = CAST(daily.CreationDate as date) AND
						 dbo.Cashiers.UserId = HeadphonesAndChargers.CreatedBy
						 WHERE dbo.Daily.AgencyId = @AgencyId 
						AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
						  AND (dbo.HeadphonesAndChargers.HeadphonesQuantity IS NOT NULL AND dbo.HeadphonesAndChargers.HeadphonesQuantity > 0)) 
						  t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;

						  
 -- Daily chargers

         INSERT INTO #Temp
                SELECT 3,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       SUM(t.Usd) AS Usd,
					   SUM(t.Cost) AS Cost,
					   NULL,
					   NULL,
					   NULL
                FROM
                (
                    SELECT 'CHARGERS' AS Type,
                           CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate,
                           'CLOSING DAILY' AS Description,
                           ISNULL(dbo.HeadphonesAndChargers.ChargersUsd, 0) AS Usd,
						   ISNULL(dbo.HeadphonesAndChargers.CostChargers, 0) * ISNULL(dbo.HeadphonesAndChargers.ChargersQuantity, 0) AS Cost
						   FROM            dbo.Daily  INNER JOIN
dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId INNER JOIN
                         dbo.HeadphonesAndChargers ON dbo.Daily.AgencyId = dbo.HeadphonesAndChargers.AgencyId
						 AND CAST(HeadphonesAndChargers.CreationDate as date) = CAST(daily.CreationDate as date) AND
						 dbo.Cashiers.UserId = HeadphonesAndChargers.CreatedBy
						 WHERE dbo.Daily.AgencyId = @AgencyId 
						AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
						  AND (dbo.HeadphonesAndChargers.ChargersQuantity IS NOT NULL AND dbo.HeadphonesAndChargers.ChargersQuantity > 0)) 
						  t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;


 -- Provider commission payment

 INSERT INTO #Temp
 SELECT  
 4,      
 'COMMISSION' AS Type,
 CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) AS CreationDate,
'COMMISSION' AS Description,
NULL,
NULL,
dbo.ProviderCommissionPayments.Usd,
dbo.ProviderCommissionPayments.Month,
dbo.ProviderCommissionPayments.Year
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE 
dbo.ProviderTypes.Code = 'C22' AND
dbo.ProviderCommissionPayments.AgencyId = @AgencyId AND
CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE) AND
CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)

         SELECT *
         FROM #Temp
         ORDER BY CreationDate,
                  [Index];
         DROP TABLE #Temp;
     END;
GO