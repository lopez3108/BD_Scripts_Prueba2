SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPropertiesBillWater]
(@PropertiesBillWaterId           INT      = NULL, 
 @PropertiesId                    INT      = NULL, 
 @ProviderCommissionPaymentTypeId INT      = NULL, 
 @FromDate                        DATETIME = NULL, 
 @ToDate                          DATETIME = NULL, 
 @BankAccountId                   INT      = NULL, 
 @BankId                          INT      = NULL, 
 @AgencyId                        INT      = NULL
)
AS
    BEGIN
        SELECT dbo.PropertiesBillWater.PropertiesBillWaterId, 
               dbo.PropertiesBillWater.PropertiesId, 
               dbo.Properties.Name AS PropertyName, 
               dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId, 
               dbo.PropertiesBillWater.FromDate, 
			   FORMAT(PropertiesBillWater.FromDate, 'MM-dd-yyyy ', 'en-US')  FromDateFormat,
               dbo.PropertiesBillWater.ToDate, 
			   FORMAT(PropertiesBillWater.ToDate, 'MM-dd-yyyy ', 'en-US')  ToDateFormat,
               dbo.PropertiesBillWater.Usd, 
               dbo.PropertiesBillWater.CheckNumber, 
               dbo.PropertiesBillWater.CheckDate, 
			   FORMAT(PropertiesBillWater.CheckDate, 'MM-dd-yyyy ', 'en-US')  CheckDateFormat,
               dbo.PropertiesBillWater.BankAccountId, 
               dbo.PropertiesBillWater.CardBankId, 
               dbo.PropertiesBillWater.AgencyId, 
               dbo.PropertiesBillWater.MoneyOrderNumber, 
               dbo.PropertiesBillWater.AchDate, 
			   FORMAT(PropertiesBillWater.AchDate, 'MM-dd-yyyy', 'en-US')  AchDateFormat,
               dbo.PropertiesBillWater.CreationDate, 
			   FORMAT(PropertiesBillWater.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PropertiesBillWater.CreatedBy,
			   dbo.PropertiesBillWater.WaterInvoice, 
               dbo.PropertiesBillWater.WaterPaid,
               dbo.BankAccounts.AccountNumber, 
               dbo.CardBanks.CardNumber, 
			   dbo.BankAccounts.AccountNumber +  '-' +  dbo.CardBanks.CardNumber  + ' ' +  '(' + dbo.Bank.Name + ')'as CardNumberr,
               dbo.Agencies.Name AS AgencyName, 
               dbo.Agencies.Code AS AgencyCode, 
               dbo.Users.Name AS CreatedByName, 
               dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId AS Expr1, 
               dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeName, 
               dbo.BankAccounts.BankId, 
               dbo.Bank.Name AS BankName, 
               dbo.PropertiesBillWater.Gallons, 
               ISNULL(dbo.PropertiesBillWater.CurrentWater, 0) AS CurrentWater, 
               ISNULL(dbo.PropertiesBillWater.CurrentSewer, 0) AS CurrentSewer, 
               ISNULL(dbo.PropertiesBillWater.CurrentWaterSewerTax, 0) AS CurrentWaterSewerTax, 
               ISNULL(dbo.PropertiesBillWater.CurrentGarbage, 0) AS CurrentGarbage, 
               ISNULL(dbo.PropertiesBillWater.CurrentPenalty, 0) AS CurrentPenalty, 
               AchDate,
               BillNumberSaved
        FROM dbo.PropertiesBillWater
             INNER JOIN dbo.Users ON dbo.PropertiesBillWater.CreatedBy = dbo.Users.UserId
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
             INNER JOIN dbo.Properties ON dbo.PropertiesBillWater.PropertiesId = dbo.Properties.PropertiesId
             LEFT OUTER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.PropertiesBillWater.BankAccountId
             LEFT OUTER JOIN dbo.Agencies ON dbo.PropertiesBillWater.AgencyId = dbo.Agencies.AgencyId
             LEFT OUTER JOIN dbo.CardBanks ON dbo.PropertiesBillWater.CardBankId = dbo.CardBanks.CardBankId
             LEFT OUTER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
        WHERE dbo.PropertiesBillWater.PropertiesBillWaterId = CASE
                                                                  WHEN @PropertiesBillWaterId IS NULL
                                                                  THEN dbo.PropertiesBillWater.PropertiesBillWaterId
                                                                  ELSE @PropertiesBillWaterId
                                                              END
              AND dbo.PropertiesBillWater.PropertiesId = CASE
                                                             WHEN @PropertiesId IS NULL
                                                             THEN dbo.PropertiesBillWater.PropertiesId
                                                             ELSE @PropertiesId
                                                         END
              AND dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId = CASE
                                                                                WHEN @ProviderCommissionPaymentTypeId IS NULL
                                                                                THEN dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId
                                                                                ELSE @ProviderCommissionPaymentTypeId
                                                                            END
              AND CAST(dbo.PropertiesBillWater.CreationDate AS DATE) >= CASE
                                                                       WHEN @FromDate IS NULL
                                                                       THEN CAST(dbo.PropertiesBillWater.CreationDate AS DATE)
                                                                       ELSE CAST(@FromDate AS DATE)
                                                                   END
              AND CAST(dbo.PropertiesBillWater.CreationDate AS DATE) <= CASE
                                                                     WHEN @ToDate IS NULL
                                                                     THEN CAST(dbo.PropertiesBillWater.CreationDate AS DATE)
                                                                     ELSE CAST(@ToDate AS DATE)
                                                                 END
              AND (@BankAccountId IS NULL
                   OR dbo.PropertiesBillWater.BankAccountId = @BankAccountId)
              AND (@BankId IS NULL
                   OR dbo.BankAccounts.BankId = @BankId)
              AND (@AgencyId IS NULL
                   OR dbo.PropertiesBillWater.AgencyId = @AgencyId)
              AND (@ProviderCommissionPaymentTypeId IS NULL
                   OR dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId = @ProviderCommissionPaymentTypeId)

                    ORDER BY dbo.PropertiesBillWater.CreationDate DESC
    END;

GO