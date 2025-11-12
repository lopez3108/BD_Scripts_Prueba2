SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetConciliationVentras] @AgencyId      INT      = NULL, 
                                                  @BankAccountId INT      = NULL, 
                                                  @BankId        INT      = NULL, 
                                                  @IsCredit      BIT      = NULL, 
                                                  @DateTo        DATETIME = NULL, 
                                                  @DateFrom      DATETIME = NULL
AS
    BEGIN
        SELECT
        (
            SELECT TOP 1 Description
            FROM dbo.ProviderTypes
            WHERE Code = 'C20'
        ) AS ProviderName, 
        dbo.ConciliationVentras.ConciliationVentraId, 
        dbo.ConciliationVentras.AgencyId, 
        dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyName, 
        dbo.ConciliationVentras.BankAccountId, 
        dbo.BankAccounts.AccountNumber, 
        dbo.Bank.BankId, 
        dbo.Bank.Name AS BankName, 
        dbo.ConciliationVentras.Date, 
		FORMAT(ConciliationVentras.Date, 'MM-dd-yyyy', 'en-US')  DateVentrasFormat,
        dbo.ConciliationVentras.IsCredit, 
        dbo.ConciliationVentras.Usd, 
        dbo.ConciliationVentras.CreatedBy, 
        dbo.Users.Name AS CreatedByName, 
        dbo.ConciliationVentras.CreationDate,
		FORMAT(ConciliationVentras.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat ,
        CASE
            WHEN dbo.ConciliationVentras.IsCredit = 1
            THEN ' CREDIT'
            ELSE ' DEBIT'
        END AS 'Type',
		CASE
            WHEN dbo.ConciliationVentras.IsCredit = 1
            THEN ' DEBIT'
            ELSE ' CREDIT'
        END AS 'Type2'
        FROM dbo.ConciliationVentras
             INNER JOIN dbo.BankAccounts ON dbo.ConciliationVentras.BankAccountId = dbo.BankAccounts.BankAccountId
             INNER JOIN dbo.Agencies ON dbo.ConciliationVentras.AgencyId = dbo.Agencies.AgencyId
             INNER JOIN dbo.Bank ON dbo.BankAccounts.BankId = dbo.Bank.BankId
             INNER JOIN dbo.Users ON dbo.Users.UserId = dbo.ConciliationVentras.CreatedBy
        WHERE dbo.ConciliationVentras.AgencyId = CASE
                                                     WHEN @AgencyId IS NULL
                                                     THEN dbo.ConciliationVentras.AgencyId
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
              AND dbo.ConciliationVentras.IsCredit = CASE
                                                         WHEN @IsCredit IS NULL
                                                         THEN dbo.ConciliationVentras.IsCredit
                                                         ELSE @IsCredit
                                                     END
              AND CAST(dbo.ConciliationVentras.CreationDate AS DATE) >= CASE
                                                                    WHEN @DateFrom IS NULL
                                                                    THEN CAST(dbo.ConciliationVentras.CreationDate AS DATE)
                                                                    ELSE CAST(@DateFrom AS DATE)
                                                                END
              AND CAST(dbo.ConciliationVentras.CreationDate AS DATE) <= CASE
                                                                    WHEN @DateTo IS NULL
                                                                    THEN CAST(dbo.ConciliationVentras.CreationDate AS DATE)
                                                                    ELSE CAST(@DateTo AS DATE)
                                                                END
        ORDER BY dbo.ConciliationVentras.CreationDate DESC;
    END;

GO