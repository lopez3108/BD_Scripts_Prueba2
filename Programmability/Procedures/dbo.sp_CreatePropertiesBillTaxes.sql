SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePropertiesBillTaxes]
(@PropertiesId                    INT, 
 @ProviderCommissionPaymentTypeId INT, 
 @FromDate                        DATETIME, 
 @ToDate                          DATETIME, 
 @Usd                             DECIMAL(18, 2), 
 @CheckNumber                     VARCHAR(15)    = NULL, 
 @CheckDate                       DATETIME       = NULL, 
 @BankAccountId                   INT            = NULL, 
 @CardBankId                      INT            = NULL, 
 @AgencyId                        INT            = NULL, 
 @MoneyOrderNumber                VARCHAR(20)    = NULL, 
 @AchDate                         DATETIME       = NULL, 
 @CreationDate                    DATETIME, 
 @CreatedBy                       INT, 
 @TaxesInvoice                    VARCHAR(1000)  = NULL, 
 @TaxesPaid                       VARCHAR(1000)  = NULL
)
AS
    BEGIN
        IF(EXISTS
        (
            SELECT *
            FROM [PropertiesBillTaxes]
            WHERE(CAST([FromDate] AS DATE) > @FromDate
                  OR CAST([ToDate] AS DATE) > @FromDate)
                 AND PropertiesId = @PropertiesId
        ))
            BEGIN
                SELECT-1;
            END;
            ELSE
            BEGIN
                INSERT INTO [dbo].[PropertiesBillTaxes]
                ([PropertiesId], 
                 [ProviderCommissionPaymentTypeId], 
                 [FromDate], 
                 [ToDate], 
                 [Usd], 
                 [CheckNumber], 
                 [CheckDate], 
                 [BankAccountId], 
                 [CardBankId], 
                 [AgencyId], 
                 [MoneyOrderNumber], 
                 [AchDate], 
                 [CreationDate], 
                 [CreatedBy],
				 TaxesInvoice,
				 TaxesPaid 
                )
                VALUES
                (@PropertiesId, 
                 @ProviderCommissionPaymentTypeId, 
                 @FromDate, 
                 @ToDate, 
                 @Usd, 
                 @CheckNumber, 
                 @CheckDate, 
                 @BankAccountId, 
                 @CardBankId, 
                 @AgencyId, 
                 @MoneyOrderNumber, 
                 @AchDate, 
                 @CreationDate, 
                 @CreatedBy,
				 @TaxesInvoice,
				 @TaxesPaid 
                );
            END;
        SELECT @@IDENTITY;
    END;
GO