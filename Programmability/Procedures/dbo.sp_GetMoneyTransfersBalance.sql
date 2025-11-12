SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMoneyTransfersBalance] @AgencyId INT = NULLL
AS
    BEGIN
        DECLARE @totalTransactions INT;
        SET @totalTransactions =
        (
            SELECT SUM(ISNULL(m.Transactions,0)) AS Expr1
            FROM dbo.MoneyTransfers AS m
                 LEFT OUTER JOIN dbo.Providers AS p ON m.ProviderId = p.ProviderId
            WHERE p.Active = 1
                  AND ShowInBalance = 1
                  AND AgencyId = @AgencyId
        );
        DECLARE @topTransactions INT;
        SET @topTransactions =
        (
            SELECT TOP 1 SUM(ISNULL(m.Transactions, 0)) AS Total
            FROM dbo.MoneyTransfers AS m
                 LEFT OUTER JOIN dbo.Providers AS p ON m.ProviderId = p.ProviderId
            WHERE p.Active = 1
                  AND ShowInBalance = 1
                  AND AgencyId = @AgencyId
            GROUP BY p.ProviderId
            ORDER BY Total DESC
        );
        DECLARE @topProviderId INT;
        SET @topProviderId =
        (
            SELECT TOP 1 p.ProviderId AS Total
            FROM dbo.MoneyTransfers AS m
                 LEFT OUTER JOIN dbo.Providers AS p ON m.ProviderId = p.ProviderId
            WHERE p.Active = 1
                  AND ShowInBalance = 1
                  AND AgencyId = @AgencyId
            GROUP BY p.ProviderId
            ORDER BY SUM(m.Transactions) DESC
        );
        DECLARE @topTransactionsSecond INT;
        SET @topTransactionsSecond =
        (
            SELECT TOP 1 SUM(m.Transactions) AS Total
            FROM dbo.MoneyTransfers AS m
                 LEFT OUTER JOIN dbo.Providers AS p ON m.ProviderId = p.ProviderId
            WHERE p.Active = 1
                  AND ShowInBalance = 1
                  AND p.ProviderId NOT IN(@topProviderId)
                 AND AgencyId = @AgencyId
            GROUP BY p.ProviderId
            ORDER BY Total DESC
        );
        SELECT SUM(m.Transactions) - @topTransactions AS TransactionsMissing, 
               --ISNULL(CONVERT(DECIMAL(18, 2), (CAST(SUM(m.Transactions) AS DECIMAL(18, 2)) * 100) / CAST(@totalTransactions AS DECIMAL(18, 2))), 0) AS Percentage, 
               p.ProviderId, 
               p.Name,
               CASE
                   WHEN(SUM(m.Transactions) - @topTransactions) = 0
                   THEN '+' + CAST(ISNULL((SUM(m.Transactions) - @topTransactionsSecond), @topTransactions) AS VARCHAR(10))
                   ELSE CAST(ISNULL((SUM(m.Transactions) - @topTransactions), '-' + CAST(@topTransactions AS VARCHAR(10))) AS VARCHAR(10))
               END AS TransactionsMissingString, 
               SUM(m.Transactions) AS TotalTransactions, 
               (SUM(m.Transactions) * 100) / NULLIF(@topTransactions, 0) AS TotalPerc
        FROM
        (
            SELECT *
            FROM dbo.MoneyTransfers
            WHERE AgencyId = @AgencyId
        ) AS m
        RIGHT OUTER JOIN dbo.Providers AS p ON m.ProviderId = p.ProviderId
        WHERE p.Active = 1
              AND ShowInBalance = 1
        GROUP BY p.ProviderId, 
                 p.Name
        ORDER BY TransactionsMissing DESC;
    END;
GO