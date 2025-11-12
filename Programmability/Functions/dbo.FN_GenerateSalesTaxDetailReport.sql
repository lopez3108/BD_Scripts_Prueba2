SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:11-10-2023
--CAMBIOS EN 5424, Refactoring reporte de sales tax 

CREATE FUNCTION [dbo].[FN_GenerateSalesTaxDetailReport](
@AgencyId   INT, 
@FromDate   DATETIME = NULL, 
@ToDate     DATETIME = NULL)
RETURNS @result TABLE
(    [Index] INT,
     Date          DATETIME, 
         Description   VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Employee      VARCHAR(1000), 
         TypeId        INT, 
         Usd           DECIMAL(18, 2), 
         Debit         DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2)
)


AS
     BEGIN
       

        INSERT INTO @result
              SELECT
          ROW_NUMBER() OVER (
          ORDER BY Query.TypeId ASC,
          CAST(Query.Date AS Date) ASC) [Index]
         ,*
        FROM (      
        
        
        SELECT CAST(p.CreationDate AS DATE) Date, 
                          i.Model + '-' + p.imei Description, 
                          'TAXES' Type, 
                          u.name Employee, 
                          2 TypeId, 
                          SUM(p.SellingValue) Usd, 
                          0 AS Debit, 
                          ISNULL(SUM(p.SellingValue), 0) * ISNULL(SUM(p.Tax), 0) / COUNT(PhoneSalesId) / 100 Credit, 
                          ISNULL(SUM(p.SellingValue), 0) * ISNULL(SUM(p.Tax), 0) / COUNT(PhoneSalesId) / 100 BalanceDetail
                  FROM PhoneSales p
                        INNER JOIN InventoryByAgency ia ON p.InventoryByAgencyId = IA.InventoryByAgencyId
                        INNER JOIN Inventory i ON i.InventoryId = IA.InventoryId
                        left JOIN PhonePlans pp ON pp.PhonePlanId = p.PhonePlanId
                        INNER JOIN users u ON u.userId = P.createdBy
                   WHERE ia.AgencyId = @AgencyId
                         AND (CAST(p.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                              OR @FromDate IS NULL)
                         AND (CAST(p.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                              OR @ToDate IS NULL)
                   GROUP BY CAST(p.CreationDate AS DATE), 
                            u.name, 
                            i.Model, 
                            p.imei,
							p.PhoneSalesId
                   UNION ALL
                   SELECT CAST(ct.Date AS DATE) Date, 
                          '****' + BA.AccountNumber + '-' + b.Name Description, 
                          'BANK PAYMENT' Type, 
                          u.name Employee, 
                          3 TypeId, 
                          0 Usd,
                         CASE
						               WHEN ct.IsCredit = 0
                               THEN  ct.Usd
                               ELSE 0
                           END Debit,
                           CASE
                               WHEN ct.IsCredit = 1
                               THEN ct.Usd
                               ELSE 0
                           END Credit,
                           CASE
                               WHEN ct.IsCredit = 1 
                               THEN -ISNULL(ct.Usd,0)
                               ELSE ISNULL(ct.Usd , 0)
                           END BalanceDetail
                   FROM ConciliationSalesTaxes ct
                        INNER JOIN Agencies A ON a.AgencyId = ct.AgencyId
                        INNER JOIN Users u ON U.UserId = ct.CreatedBy
                        INNER JOIN BankAccounts ba ON ba.BankAccountId = CT.BankAccountId
                        INNER JOIN Bank b ON b.BankId = ba.BankId
                   WHERE ct.AgencyId = @AgencyId
                         AND (CAST(ct.Date AS DATE) >= CAST(@FromDate AS DATE)
                              OR @FromDate IS NULL)
                         AND (CAST(ct.Date AS DATE) <= CAST(@ToDate AS DATE)
                              OR @ToDate IS NULL)
      
        ) AS Query


         RETURN;
     END;





GO