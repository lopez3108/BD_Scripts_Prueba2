SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePropertiesBillOther]
 (
      @PropertiesId INT,
	  @ApartmentId INT = NULL,
	  @Description VARCHAR(250),
	  @IsCredit BIT,
           @ProviderCommissionPaymentTypeId INT,
           @Date DATETIME,
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
		   @OtherInvoice VARCHAR(1000) = NULL
    )
AS 

BEGIN

INSERT INTO [dbo].[PropertiesBillOthers]
           ([PropertiesId]
		   ,[ApartmentId]
		   ,[Description]
		   ,[IsCredit]
           ,[ProviderCommissionPaymentTypeId]
           ,[Date]
           ,[Usd]
           ,[CheckNumber]
           ,[CheckDate]
           ,[BankAccountId]
           ,[CardBankId]
           ,[AgencyId]
           ,[MoneyOrderNumber]
           ,[AchDate]
           ,[CreationDate]
           ,[CreatedBy]
		   ,[OtherInvoice])
     VALUES
           (@PropertiesId
		   ,@ApartmentId
		   ,@Description
		   ,@IsCredit
           ,@ProviderCommissionPaymentTypeId
           ,@Date
           ,@Usd
           ,@CheckNumber
           ,@CheckDate
           ,@BankAccountId
           ,@CardBankId
           ,@AgencyId
           ,@MoneyOrderNumber
           ,@AchDate
           ,@CreationDate
           ,@CreatedBy
		   ,@OtherInvoice)


		   SELECT @@IDENTITY


	END
GO