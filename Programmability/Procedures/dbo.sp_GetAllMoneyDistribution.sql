SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllMoneyDistribution] @CashierId INT = NULL,
                                                   @AgencyId  INT = NULL
AS
     BEGIN
         SELECT m.MoneyDistributionId,
                m.CashierId,
--                m.AgencyId,
--                m.ProviderId,
                m.BankAccountId,
                m.IsDefault,
--                a.Name Agency,
                u.Name Cashier
--                p.Name Provider

     FROM MoneyDistribution m
--              INNER JOIN [dbo].[Agencies] a ON m.AgencyId = a.AgencyId
              INNER JOIN [dbo].[Cashiers] c ON c.CashierId = m.CashierId
              INNER JOIN [dbo].[Users] u ON u.UserId = c.UserId
--              LEFT JOIN [dbo].[Providers] p ON p.ProviderId = m.ProviderId
              LEFT JOIN [dbo].BankAccounts B ON B.BankAccountId = m.BankAccountId
         WHERE(m.CashierId = @CashierId
               OR @CashierId IS NULL)
--              AND (m.AgencyId = @AgencyId
--                   OR @AgencyId IS NULL)
         ORDER BY  m.IsDefault desc
     END;
GO