SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPropertiesBillLabor]
(@PropertiesBillLaborId           INT      = NULL, 
 @ApartmentId                     INT      = NULL, 
 @PropertiesId                    INT      = NULL, 
 @ProviderCommissionPaymentTypeId INT      = NULL, 
 @FromDate                        DATETIME = NULL, 
 @ToDate                          DATETIME = NULL, 
 @BankAccountId                   INT      = NULL, 
 @BankId                          INT      = NULL, 
 @AgencyId                        INT      = NULL,
 @CurrentDate DATETIME,
 @UserId INT
)
AS
    BEGIN
        SELECT dbo.PropertiesBillLabor.PropertiesBillLaborId, 
               dbo.PropertiesBillLabor.PropertiesId, 
               dbo.PropertiesBillLabor.ApartmentId, 
               dbo.Apartments.Number, 
               dbo.PropertiesBillLabor.Name AS LaborName, 
               dbo.PropertiesBillLabor.Note, 
               dbo.Properties.Name AS PropertyName, 
               dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId, 
               dbo.PropertiesBillLabor.FromDate, 
			   FORMAT(PropertiesBillLabor.FromDate, 'MM-dd-yyyy ', 'en-US')  FromDateFormat,
               dbo.PropertiesBillLabor.ToDate, 
			   FORMAT(PropertiesBillLabor.ToDate, 'MM-dd-yyyy ', 'en-US')  ToDateFormat,
               dbo.PropertiesBillLabor.Usd, 
               dbo.PropertiesBillLabor.CheckNumber, 
               dbo.PropertiesBillLabor.CheckDate, 
			   FORMAT(PropertiesBillLabor.CheckDate, 'MM-dd-yyyy ', 'en-US')  CheckDateFormat,
               dbo.PropertiesBillLabor.BankAccountId, 
               dbo.PropertiesBillLabor.CardBankId, 
               dbo.PropertiesBillLabor.AgencyId, 
               dbo.PropertiesBillLabor.MoneyOrderNumber, 
               dbo.PropertiesBillLabor.AchDate, 
			   FORMAT(PropertiesBillLabor.AchDate, 'MM-dd-yyyy', 'en-US')  AchDateFormat,
               dbo.PropertiesBillLabor.CreationDate, 
			   FORMAT(PropertiesBillLabor.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PropertiesBillLabor.CreatedBy, 
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
               dbo.PropertiesBillLabor.DepositUsed, 
               dbo.PropertiesBillLabor.ContractId,
			   dbo.PropertiesBillLabor.LaborInvoice, 
               AchDate,
			   CASE 
			   WHEN ((dbo.PropertiesBillLabor.CreatedBy = @UserId) AND (CAST(@CurrentDate as DATE) = CAST(dbo.PropertiesBillLabor.CreationDate as DATE))) THEN
			   CAST(1 as BIT) ELSE
			   CAST(0 as BIT) END AS CanDelete
        FROM dbo.PropertiesBillLabor
             INNER JOIN dbo.Users ON dbo.PropertiesBillLabor.CreatedBy = dbo.Users.UserId
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
             INNER JOIN dbo.Properties ON dbo.PropertiesBillLabor.PropertiesId = dbo.Properties.PropertiesId
             LEFT OUTER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.PropertiesBillLabor.BankAccountId
             LEFT OUTER JOIN dbo.Agencies ON dbo.PropertiesBillLabor.AgencyId = dbo.Agencies.AgencyId
             LEFT OUTER JOIN dbo.CardBanks ON dbo.PropertiesBillLabor.CardBankId = dbo.CardBanks.CardBankId
             LEFT OUTER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
             LEFT OUTER JOIN dbo.Apartments ON dbo.Apartments.ApartmentsId = dbo.PropertiesBillLabor.ApartmentId
        WHERE dbo.PropertiesBillLabor.PropertiesBillLaborId = CASE
                                                                  WHEN @PropertiesBillLaborId IS NULL
                                                                  THEN dbo.PropertiesBillLabor.PropertiesBillLaborId
                                                                  ELSE @PropertiesBillLaborId
                                                              END
              AND dbo.PropertiesBillLabor.PropertiesId = CASE
                                                             WHEN @PropertiesId IS NULL
                                                             THEN dbo.PropertiesBillLabor.PropertiesId
                                                             ELSE @PropertiesId
                                                         END
              AND dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId = CASE
                                                                                WHEN @ProviderCommissionPaymentTypeId IS NULL
                                                                                THEN dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId
                                                                                ELSE @ProviderCommissionPaymentTypeId
                                                                            END
              AND CAST(dbo.PropertiesBillLabor.CreationDate AS DATE) >= CASE
                                                                       WHEN @FromDate IS NULL
                                                                       THEN CAST(dbo.PropertiesBillLabor.CreationDate AS DATE)
                                                                       ELSE CAST(@FromDate AS DATE)
                                                                   END
              AND CAST(dbo.PropertiesBillLabor.CreationDate AS DATE) <= CASE
                                                                     WHEN @ToDate IS NULL
                                                                     THEN CAST(dbo.PropertiesBillLabor.CreationDate AS DATE)
                                                                     ELSE CAST(@ToDate AS DATE)
                                                                 END
              AND (@BankAccountId IS NULL
                   OR dbo.PropertiesBillLabor.BankAccountId = @BankAccountId)
              AND (@ApartmentId IS NULL
                   OR dbo.PropertiesBillLabor.ApartmentId = @ApartmentId)
              AND (@BankId IS NULL
                   OR dbo.BankAccounts.BankId = @BankId)
              AND (@AgencyId IS NULL
                   OR dbo.PropertiesBillLabor.AgencyId = @AgencyId)
              AND (@ProviderCommissionPaymentTypeId IS NULL
                   OR dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId = @ProviderCommissionPaymentTypeId)

                    ORDER BY dbo.PropertiesBillLabor.CreationDate DESC
    END;

GO