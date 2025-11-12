SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllAgenciesCashiersMoneyDistributionByCashierId] @CashierId INT = NULL,
                                                                              @AgencyId  INT = NULL
AS
     BEGIN
         SELECT
                m.CashierId,
               -- m.AgencyId,
                --a.Name AgencyName,
                u.Name CashierName
         FROM MoneyDistribution m
            --  INNER JOIN [dbo].[Agencies] a ON m.AgencyId = a.AgencyId
              INNER JOIN [dbo].[Cashiers] c ON c.CashierId = m.CashierId
              INNER JOIN [dbo].[Users] u ON u.UserId = c.UserId
            --  LEFT JOIN [dbo].[Providers] p ON p.ProviderId = m.ProviderId
              LEFT JOIN [dbo].BankAccounts B ON B.BankAccountId = m.BankAccountId
         WHERE(
               m.CashierId = @CashierId
               OR @CashierId IS NULL)
--              AND (m.AgencyId = @AgencyId
--                   OR @AgencyId IS NULL)
         GROUP BY 
                  m.CashierId,
--                  m.AgencyId,
                  --a.Name,
                  u.Name
        -- ORDER BY a.Name ;
     END;
GO