SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePropertiesBillInsurance]
 (
      @PropertiesId INT,
           @ProviderCommissionPaymentTypeId INT,
           @FromDate DATETIME,
           @ToDate DATETIME,
           @Usd DECIMAL(18,2),
           @CheckNumber VARCHAR(15) = NULL,
           @CheckDate DATETIME = NULL,
           @BankAccountId INT = NULL,
           @CardBankId INT = NULL,
           @AgencyId INT = NULL,
           @MoneyOrderNumber VARCHAR(20) = NULL,
           @AchDate DATETIME = NULL,
           @CreationDate DATETIME,
           @CreatedBy INT,
               @PolicyNumber VARCHAR(20) = NULL
    )
AS 

BEGIN

IF(EXISTS(SELECT * FROM [PropertiesBillInsurance] WHERE 
(CAST([FromDate] as DATE) > @FromDate OR 
CAST([ToDate] as DATE) > @FromDate) AND
PropertiesId = @PropertiesId))
BEGIN

SELECT -1

END
ELSE
BEGIN

INSERT INTO [dbo].[PropertiesBillInsurance]
           ([PropertiesId]
           ,[ProviderCommissionPaymentTypeId]
           ,[FromDate]
           ,[ToDate]
           ,[Usd]
           ,[CheckNumber]
           ,[CheckDate]
           ,[BankAccountId]
           ,[CardBankId]
           ,[AgencyId]
           ,[MoneyOrderNumber]
           ,[AchDate]
           ,[CreationDate]
           ,[CreatedBy],
           PolicyNumberSaved)
     VALUES
           (@PropertiesId
           ,@ProviderCommissionPaymentTypeId
           ,@FromDate
           ,@ToDate
           ,@Usd
           ,@CheckNumber
           ,@CheckDate
           ,@BankAccountId
           ,@CardBankId
           ,@AgencyId
           ,@MoneyOrderNumber
           ,@AchDate
           ,@CreationDate
           ,@CreatedBy,
           @PolicyNumber)


		   SELECT @@IDENTITY

END
	END

GO