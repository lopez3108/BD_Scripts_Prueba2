SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportPhoneCards]
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
          Cost           DECIMAL(18, 2) NULL,
		  Commission           DECIMAL(18, 2) NULL,
		  CreditCost           DECIMAL(18, 2) NULL,
		  CreditCommission         DECIMAL(18, 2) NULL,
		  [Month] INT NULL,
		  [Year] INT NULL
         );


-- Initial cash balance
         INSERT INTO #Temp
                SELECT 
				1,
                       'INITIAL BALANCE',
                       CAST(@FromDate AS DATE),
                       'INITIAL BALANCE',
					   dbo.fn_CalculatePhoneCardsInitialBalanceCost(@AgencyId, @FromDate),
					   dbo.fn_CalculatePhoneCardsInitialBalanceCommission(@AgencyId, @FromDate),
					   NULL,
					   NULL,
					   NULL,
					   NULL
                       


-- Daily

         INSERT INTO #Temp
SELECT       
2,
t.Type,
t.CreationDate,
t.Description,
SUM(t.Usd),
SUM(t.Commission),
NULL,
NULL,
NULL,
NULL
FROM  ( SELECT
'DAILY' as Type,
CAST(dbo.PhoneCards.CreationDate AS DATE) as CreationDate,
'CLOSING DAILY' as Description,
ISNULL(dbo.PhoneCards.PhoneCardsUsd, 0) AS Usd,
(ISNULL(dbo.PhoneCards.PhoneCardsUsd, 0) * ISNULL(dbo.PhoneCards.Commission, 0) / 100)  AS Commission
        FROM  dbo.PhoneCards
						 WHERE 
						 dbo.PhoneCards.AgencyId = @AgencyId 
						AND CAST(dbo.PhoneCards.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.PhoneCards.CreationDate AS DATE) <= CAST(@ToDate AS DATE)

  ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;


-- Commissions

         INSERT INTO #Temp
SELECT        
3,
'COMMISSIONS',
CAST(dbo.ProviderCommissionPayments.CreationDate as DATE),
'COMMISSIONS ',
NULL,
NULL,
NULL,
Usd,
dbo.ProviderCommissionPayments.Month,
dbo.ProviderCommissionPayments.Year
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE 
						 dbo.ProviderTypes.Code = 'C23' AND
						 dbo.ProviderCommissionPayments.AgencyId = @AgencyId 
						AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)


						  -- Payments

         INSERT INTO #Temp

		 SELECT
		 4,
t.Type,
CAST(t.CreationDate as DATE),
t.Description,
NULL,
NULL,
SUM(t.Usd),
NULL,
NULL,
NULL
FROM (SELECT  
'PAYMENTS' as Type,    
CAST(dbo.Expenses.CreatedOn as DATE) as CreationDate,
'CLOSING DAILY' as Description,
(ISNULL(dbo.Expenses.Usd,0) * -1) as Usd
FROM            dbo.Expenses INNER JOIN
                         dbo.ExpensesType ON dbo.Expenses.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
						 WHERE 
						 dbo.ExpensesType.Code = 'C03' AND
						 dbo.Expenses.AgencyId = @AgencyId AND
						 CAST(dbo.Expenses.CreatedOn AS DATE) >= CAST(@FromDate AS DATE) AND
                         CAST(dbo.Expenses.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
						  ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;


         SELECT *
         FROM #Temp
         ORDER BY CreationDate,
                  [Index];
         DROP TABLE #Temp;
     END;
GO