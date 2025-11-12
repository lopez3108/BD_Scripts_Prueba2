SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetConciliationVentra] @AgencyId      INT      = NULL,
                                                 @BankAccountId INT      = NULL,
                                                 @BankId        INT      = NULL,
                                                 @IsCredit      BIT      = NULL,
                                                 @DateTo        DATETIME = NULL,
                                                 @DateFrom      DATETIME = NULL
AS
     BEGIN
         SELECT dbo.ConciliationVentra.ConciliationVentraId,
                dbo.ConciliationVentra.AgencyId,
                dbo.Agencies.Code+' - '+dbo.Agencies.Name AS AgencyName,
                dbo.ConciliationVentra.BankAccountId,
                dbo.BankAccounts.AccountNumber,
                dbo.Bank.BankId,
                dbo.Bank.Name AS BankName,
                dbo.ConciliationVentra.Date,
                dbo.ConciliationVentra.IsCredit,
                dbo.ConciliationVentra.Usd,
                dbo.ConciliationVentra.CreatedBy,
                dbo.Users.Name AS CreatedByName,
                dbo.ConciliationVentra.CreationDate,
                CASE
                    WHEN dbo.ConciliationVentra.IsCredit = 1
                    THEN '+ CREDIT'
                    ELSE '- DEBIT'
                END AS 'Type'
         FROM dbo.ConciliationVentra
              INNER JOIN dbo.BankAccounts ON dbo.ConciliationVentra.BankAccountId = dbo.BankAccounts.BankAccountId
              INNER JOIN dbo.Agencies ON dbo.ConciliationVentra.AgencyId = dbo.Agencies.AgencyId
              INNER JOIN dbo.Bank ON dbo.BankAccounts.BankId = dbo.Bank.BankId
              INNER JOIN dbo.Users ON dbo.Users.UserId = dbo.ConciliationVentra.CreatedBy
         WHERE dbo.ConciliationVentra.AgencyId = CASE
                                                     WHEN @AgencyId IS NULL
                                                     THEN dbo.ConciliationVentra.AgencyId
                                                     ELSE @AgencyId
                                                 END
               AND dbo.BankAccounts.BankAccountId = CASE
                                                        WHEN @BankAccountId IS NULL
                                                        THEN dbo.BankAccounts.BankAccountId
                                                        ELSE @BankAccountId
                                                    END
               AND dbo.Bank.BankId = CASE
                                         WHEN @BankId IS NULL
                                         THEN dbo.Bank.BankId
                                         ELSE @BankId
                                     END
               AND dbo.ConciliationVentra.IsCredit = CASE
                                                         WHEN @IsCredit IS NULL
                                                         THEN dbo.ConciliationVentra.IsCredit
                                                         ELSE @IsCredit
                                                     END
               AND CAST(dbo.ConciliationVentra.CreationDate AS DATE) >= CASE
                                                                    WHEN @DateFrom IS NULL
                                                                    THEN CAST(dbo.ConciliationVentra.CreationDate AS DATE)
                                                                    ELSE CAST(@DateFrom AS DATE)
                                                                END
               AND CAST(dbo.ConciliationVentra.CreationDate AS DATE) <= CASE
                                                                    WHEN @DateTo IS NULL
                                                                    THEN CAST(dbo.ConciliationVentra.CreationDate AS DATE)
                                                                    ELSE CAST(@DateTo AS DATE)
                                                                END
         ORDER BY dbo.ConciliationVentra.CreationDate DESC;
     END;

GO