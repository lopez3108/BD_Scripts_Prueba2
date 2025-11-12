SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPropertiesBillOther]
(@PropertiesBillOthersId          INT      = NULL, 
 @ApartmentId                     INT      = NULL, 
 @PropertiesId                    INT      = NULL, 
 @ProviderCommissionPaymentTypeId INT      = NULL, 
 @FromDate                        DATETIME = NULL, 
 @ToDate                          DATETIME = NULL, 
 @BankAccountId                   INT      = NULL, 
 @BankId                          INT      = NULL, 
 @AgencyId                        INT      = NULL, 
 @IsCredit                        BIT      = NULL
)
AS
    BEGIN
        SELECT dbo.PropertiesBillOthers.PropertiesBillOtherId, 
               dbo.PropertiesBillOthers.PropertiesId, 
               dbo.PropertiesBillOthers.ApartmentId, 
               dbo.Apartments.Number, 
               dbo.PropertiesBillOthers.Description AS OtherDescription, 
               dbo.PropertiesBillOthers.IsCredit,
               CASE
                   WHEN dbo.PropertiesBillOthers.IsCredit = 1
                   THEN ' CREDIT'
                   ELSE ' DEBIT'
               END AS 'Transaction', 
               dbo.Properties.Name AS PropertyName, 
               dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId, 
               dbo.PropertiesBillOthers.Date, 
			   FORMAT(PropertiesBillOthers.Date, 'MM-dd-yyyy ', 'en-US')  DateFormat,
               dbo.PropertiesBillOthers.Usd, 
               dbo.PropertiesBillOthers.CheckNumber, 
               dbo.PropertiesBillOthers.CheckDate, 
			   FORMAT(PropertiesBillOthers.CheckDate, 'MM-dd-yyyy ', 'en-US')  CheckDateFormat,
               dbo.PropertiesBillOthers.BankAccountId, 
               dbo.PropertiesBillOthers.CardBankId, 
               dbo.PropertiesBillOthers.AgencyId, 
               dbo.PropertiesBillOthers.MoneyOrderNumber, 
               dbo.PropertiesBillOthers.AchDate, 
			   FORMAT(PropertiesBillOthers.AchDate, 'MM-dd-yyyy', 'en-US')  AchDateFormat,
               dbo.PropertiesBillOthers.CreationDate,
			   FORMAT(PropertiesBillOthers.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PropertiesBillOthers.CreatedBy, 
			   dbo.PropertiesBillOthers.OtherInvoice, 
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
               AchDate
        FROM dbo.PropertiesBillOthers
             INNER JOIN dbo.Users ON dbo.PropertiesBillOthers.CreatedBy = dbo.Users.UserId
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
             INNER JOIN dbo.Properties ON dbo.PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId
             LEFT OUTER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.PropertiesBillOthers.BankAccountId
             LEFT OUTER JOIN dbo.Agencies ON dbo.PropertiesBillOthers.AgencyId = dbo.Agencies.AgencyId
             LEFT OUTER JOIN dbo.CardBanks ON dbo.PropertiesBillOthers.CardBankId = dbo.CardBanks.CardBankId
             LEFT OUTER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
             LEFT OUTER JOIN dbo.Apartments ON dbo.Apartments.ApartmentsId = dbo.PropertiesBillOthers.ApartmentId
        WHERE(CAST(PropertiesBillOthers.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
              OR @FromDate IS NULL)
             AND (CAST(PropertiesBillOthers.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                  OR @ToDate IS NULL)
             AND dbo.PropertiesBillOthers.PropertiesBillOtherId = CASE
                                                                      WHEN @PropertiesBillOthersId IS NULL
                                                                      THEN dbo.PropertiesBillOthers.PropertiesBillOtherId
                                                                      ELSE @PropertiesBillOthersId
                                                                  END
             AND dbo.PropertiesBillOthers.PropertiesId = CASE
                                                             WHEN @PropertiesId IS NULL
                                                             THEN dbo.PropertiesBillOthers.PropertiesId
                                                             ELSE @PropertiesId
                                                         END
             AND dbo.PropertiesBillOthers.IsCredit = CASE
                                                         WHEN @IsCredit IS NULL
                                                         THEN dbo.PropertiesBillOthers.IsCredit
                                                         ELSE @IsCredit
                                                     END
             AND dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId = CASE
                                                                                WHEN @ProviderCommissionPaymentTypeId IS NULL
                                                                                THEN dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId
                                                                                ELSE @ProviderCommissionPaymentTypeId
                                                                            END
             AND (@BankAccountId IS NULL
                  OR dbo.PropertiesBillOthers.BankAccountId = @BankAccountId)
             AND (@ApartmentId IS NULL
                  OR dbo.PropertiesBillOthers.ApartmentId = @ApartmentId)
             AND (@BankId IS NULL
                  OR dbo.BankAccounts.BankId = @BankId)
             AND (@AgencyId IS NULL
                  OR dbo.PropertiesBillOthers.AgencyId = @AgencyId)
             AND (@ProviderCommissionPaymentTypeId IS NULL
                  OR dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId = @ProviderCommissionPaymentTypeId)
                   ORDER BY dbo.PropertiesBillOthers.CreationDate DESC
    END;

GO