SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPropertiesBillTaxes]
(@PropertiesBillTaxesId           INT      = NULL, 
 @PropertiesId                    INT      = NULL, 
 @ProviderCommissionPaymentTypeId INT      = NULL, 
 @FromDate                        DATETIME = NULL, 
 @ToDate                          DATETIME = NULL, 
 @BankAccountId                   INT      = NULL, 
 @BankId                          INT      = NULL, 
 @AgencyId                        INT      = NULL, 
 @Date                            DATETIME, 
 @Status                          INT      = NULL
)
AS
    BEGIN
        SELECT dbo.PropertiesBillTaxes.PropertiesBillTaxesId, 
               dbo.PropertiesBillTaxes.PropertiesId, 
               dbo.Properties.Name AS PropertyName, 
               dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId, 
               dbo.PropertiesBillTaxes.FromDate, 
			   FORMAT(PropertiesBillTaxes.FromDate, 'MM-dd-yyyy ', 'en-US')  FromDateFormat,
               dbo.PropertiesBillTaxes.ToDate, 
			   FORMAT(PropertiesBillTaxes.ToDate, 'MM-dd-yyyy ', 'en-US')  ToDateFormat,
               dbo.PropertiesBillTaxes.Usd, 
               dbo.PropertiesBillTaxes.CheckNumber, 
               dbo.PropertiesBillTaxes.CheckDate, 
			   FORMAT(PropertiesBillTaxes.CheckDate, 'MM-dd-yyyy ', 'en-US')  CheckDateFormat,
               dbo.PropertiesBillTaxes.BankAccountId, 
               dbo.PropertiesBillTaxes.CardBankId, 
               dbo.PropertiesBillTaxes.AgencyId, 
               dbo.PropertiesBillTaxes.MoneyOrderNumber, 
               dbo.PropertiesBillTaxes.AchDate, 
			   FORMAT(PropertiesBillTaxes.AchDate, 'MM-dd-yyyy', 'en-US')  AchDateFormat,
               dbo.PropertiesBillTaxes.CreationDate, 
			   FORMAT(PropertiesBillTaxes.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PropertiesBillTaxes.CreatedBy, 
			   dbo.PropertiesBillTaxes.TaxesPaid, 
			   dbo.PropertiesBillTaxes.TaxesInvoice, 
               dbo.BankAccounts.AccountNumber, 
               dbo.CardBanks.CardNumber,
			   dbo.BankAccounts.AccountNumber +  '-' +  dbo.CardBanks.CardNumber + ' ' +  '(' + dbo.Bank.Name + ')' as CardNumberr,
               dbo.Agencies.Name AS AgencyName, 
               dbo.Agencies.Code AS AgencyCode, 
               dbo.Users.Name AS CreatedByName, 
               dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId AS Expr1, 
               dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeName, 
               dbo.BankAccounts.BankId, 
               dbo.Bank.Name AS BankName,
               CASE
                   WHEN dbo.[fn_PropertiesBillTaxesStatus](dbo.PropertiesBillTaxes.PropertiesBillTaxesId, @Date) = 1
                   THEN 'PAID'
                   ELSE 'EXPIRED'
               END AS Status, 
               dbo.PropertiesBillTaxes.AchDate
        FROM dbo.PropertiesBillTaxes
             INNER JOIN dbo.Users ON dbo.PropertiesBillTaxes.CreatedBy = dbo.Users.UserId
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
             INNER JOIN dbo.Properties ON dbo.PropertiesBillTaxes.PropertiesId = dbo.Properties.PropertiesId
             LEFT OUTER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.PropertiesBillTaxes.BankAccountId
             LEFT OUTER JOIN dbo.Agencies ON dbo.PropertiesBillTaxes.AgencyId = dbo.Agencies.AgencyId
             LEFT OUTER JOIN dbo.CardBanks ON dbo.PropertiesBillTaxes.CardBankId = dbo.CardBanks.CardBankId
             LEFT OUTER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
        WHERE dbo.PropertiesBillTaxes.PropertiesBillTaxesId = CASE
                                                                  WHEN @PropertiesBillTaxesId IS NULL
                                                                  THEN dbo.PropertiesBillTaxes.PropertiesBillTaxesId
                                                                  ELSE @PropertiesBillTaxesId
                                                              END
              AND dbo.PropertiesBillTaxes.PropertiesId = CASE
                                                             WHEN @PropertiesId IS NULL
                                                             THEN dbo.PropertiesBillTaxes.PropertiesId
                                                             ELSE @PropertiesId
                                                         END
              AND dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId = CASE
                                                                                WHEN @ProviderCommissionPaymentTypeId IS NULL
                                                                                THEN dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId
                                                                                ELSE @ProviderCommissionPaymentTypeId
                                                                            END
              AND CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE) >= CASE
                                                                       WHEN @FromDate IS NULL
                                                                       THEN CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE)
                                                                       ELSE CAST(@FromDate AS DATE)
                                                                   END
              AND CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE) <= CASE
                                                                     WHEN @ToDate IS NULL
                                                                     THEN CAST(dbo.PropertiesBillTaxes.CreationDate AS DATE)
                                                                     ELSE CAST(@ToDate AS DATE)
                                                                 END
              AND (@BankAccountId IS NULL
                   OR dbo.PropertiesBillTaxes.BankAccountId = @BankAccountId)
              AND (@BankId IS NULL
                   OR dbo.BankAccounts.BankId = @BankId)
              AND (@AgencyId IS NULL
                   OR dbo.PropertiesBillTaxes.AgencyId = @AgencyId)
              AND (@ProviderCommissionPaymentTypeId IS NULL
                   OR dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId = @ProviderCommissionPaymentTypeId)
              AND dbo.[fn_PropertiesBillTaxesStatus](dbo.PropertiesBillTaxes.PropertiesBillTaxesId, @Date) = CASE
                                                                                                                 WHEN @Status IS NOT NULL
                                                                                                                 THEN @Status
                                                                                                                 ELSE dbo.[fn_PropertiesBillTaxesStatus](dbo.PropertiesBillTaxes.PropertiesBillTaxesId, @Date)
                                                                                                             END
        ORDER BY dbo.PropertiesBillTaxes.CreationDate DESC
           
    END;

GO