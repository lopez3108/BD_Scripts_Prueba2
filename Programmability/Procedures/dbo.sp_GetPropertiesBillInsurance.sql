SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPropertiesBillInsurance]
(@PropertiesBillInsuranceId       INT      = NULL, 
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
        SELECT dbo.PropertiesBillInsurance.PropertiesBillInsuranceId, 
               dbo.PropertiesBillInsurance.PropertiesId, 
               dbo.Properties.Name AS PropertyName, 
               dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId, 
               dbo.PropertiesBillInsurance.FromDate, 
			   FORMAT(PropertiesBillInsurance.FromDate, 'MM-dd-yyyy ', 'en-US')  FromDateFormat,
               dbo.PropertiesBillInsurance.ToDate,
			   FORMAT(PropertiesBillInsurance.ToDate, 'MM-dd-yyyy ', 'en-US')  ToDateFormat,
               dbo.PropertiesBillInsurance.Usd, 
               dbo.PropertiesBillInsurance.CheckNumber, 
               dbo.PropertiesBillInsurance.CheckDate, 
			   FORMAT(PropertiesBillInsurance.CheckDate, 'MM-dd-yyyy ', 'en-US')  CheckDateFormat,
               dbo.PropertiesBillInsurance.BankAccountId, 
               dbo.PropertiesBillInsurance.CardBankId, 
               dbo.PropertiesBillInsurance.AgencyId, 
               dbo.PropertiesBillInsurance.MoneyOrderNumber, 
               dbo.PropertiesBillInsurance.AchDate,
			   FORMAT(PropertiesBillInsurance.AchDate, 'MM-dd-yyyy', 'en-US')  AchDateFormat,
               dbo.PropertiesBillInsurance.CreationDate, 
			    FORMAT(PropertiesBillInsurance.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PropertiesBillInsurance.CreatedBy, 
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
                   WHEN dbo.[fn_PropertiesBillInsuranceStatus](dbo.PropertiesBillInsurance.PropertiesBillInsuranceId, @Date) = 1
                   THEN 'PAID'
                   ELSE 'EXPIRED'
               END AS Status, 
               AchDate,
               PolicyNumberSaved
        FROM dbo.PropertiesBillInsurance
             INNER JOIN dbo.Users ON dbo.PropertiesBillInsurance.CreatedBy = dbo.Users.UserId
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
             INNER JOIN dbo.Properties ON dbo.PropertiesBillInsurance.PropertiesId = dbo.Properties.PropertiesId
             LEFT OUTER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.PropertiesBillInsurance.BankAccountId
             LEFT OUTER JOIN dbo.Agencies ON dbo.PropertiesBillInsurance.AgencyId = dbo.Agencies.AgencyId
             LEFT OUTER JOIN dbo.CardBanks ON dbo.PropertiesBillInsurance.CardBankId = dbo.CardBanks.CardBankId
             LEFT OUTER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
        WHERE dbo.PropertiesBillInsurance.PropertiesBillInsuranceId = CASE
                                                                          WHEN @PropertiesBillInsuranceId IS NULL
                                                                          THEN dbo.PropertiesBillInsurance.PropertiesBillInsuranceId
                                                                          ELSE @PropertiesBillInsuranceId
                                                                      END
              AND dbo.PropertiesBillInsurance.PropertiesId = CASE
                                                                 WHEN @PropertiesId IS NULL
                                                                 THEN dbo.PropertiesBillInsurance.PropertiesId
                                                                 ELSE @PropertiesId
                                                             END
              AND dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId = CASE
                                                                                    WHEN @ProviderCommissionPaymentTypeId IS NULL
                                                                                    THEN dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId
                                                                                    ELSE @ProviderCommissionPaymentTypeId
                                                                                END
              AND CAST(dbo.PropertiesBillInsurance.CreationDate AS DATE) >= CASE
                                                                           WHEN @FromDate IS NULL
                                                                           THEN CAST(dbo.PropertiesBillInsurance.CreationDate AS DATE)
                                                                           ELSE CAST(@FromDate AS DATE)
                                                                       END
              AND CAST(dbo.PropertiesBillInsurance.CreationDate AS DATE) <= CASE
                                                                         WHEN @ToDate IS NULL
                                                                         THEN CAST(dbo.PropertiesBillInsurance.CreationDate AS DATE)
                                                                         ELSE CAST(@ToDate AS DATE)
                                                                     END
              AND (@BankAccountId IS NULL
                   OR dbo.PropertiesBillInsurance.BankAccountId = @BankAccountId)
              AND (@BankId IS NULL
                   OR dbo.BankAccounts.BankId = @BankId)
              AND (@AgencyId IS NULL
                   OR dbo.PropertiesBillInsurance.AgencyId = @AgencyId)
              AND (@ProviderCommissionPaymentTypeId IS NULL
                   OR dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId = @ProviderCommissionPaymentTypeId)
              AND dbo.[fn_PropertiesBillInsuranceStatus](dbo.PropertiesBillInsurance.PropertiesBillInsuranceId, @Date) = CASE
                                                                                                                             WHEN @Status IS NOT NULL
                                                                                                                             THEN @Status
                                                                                                                             ELSE dbo.[fn_PropertiesBillInsuranceStatus](dbo.PropertiesBillInsurance.PropertiesBillInsuranceId, @Date)
                                                                                                                         END
        ORDER BY dbo.PropertiesBillInsurance.CreationDate DESC
                 
    END;

GO