SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePropertiesBillWater]
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
		   @Gallons DECIMAL(18,2),
		   @CurrentWater DECIMAL(18,2) = NULL,
	@CurrentSewer DECIMAL(18,2) = NULL,
	@CurrentWaterSewerTax decimal(18,2) = NULL,
	@CurrentGarbage decimal(18,2) = NULL,
	@CurrentPenalty decimal(18,2) = NULL,
	@WaterInvoice varchar(1000) = NULL,
	@WaterPaid varchar(1000) = NULL,
  	@BillNumber varchar(20) = NULL

    )
AS 

BEGIN

INSERT INTO [dbo].[PropertiesBillWater]
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
           ,[CreatedBy]
           ,[Gallons]
           ,[CurrentWater]
           ,[CurrentSewer]
           ,[CurrentWaterSewerTax]
           ,[CurrentGarbage]
           ,[CurrentPenalty]
		   ,[WaterInvoice]
           ,[WaterPaid],
           BillNumberSaved)
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
           ,@CreatedBy
           ,@Gallons
           ,@CurrentWater
           ,@CurrentSewer
           ,@CurrentWaterSewerTax
           ,@CurrentGarbage
           ,@CurrentPenalty
		   ,@WaterInvoice
		   ,@WaterPaid,
       @BillNumber)


		   SELECT @@IDENTITY


	END

GO