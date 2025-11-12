SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePaymentAgenttoagent]

@AgencyFromId INT,
@AgencyToId INT,
@Usd DECIMAL(18,2),
@CreationDate DATETIME,
@CreatedBy INT,
@Date DATETIME,
@Note VARCHAR(180),
@CheckNumber VARCHAR(15) = NULL,
           @CheckDate DATETIME = NULL,
           @BankAccountId INT = NULL,
           @CardBankId INT = NULL,
           @AgencyId INT = NULL,
           @MoneyOrderNumber VARCHAR(20) = NULL,
           @AchDate DATETIME = NULL,
		   @ProviderCommissionPaymentTypeId INT

AS
     BEGIN


INSERT INTO [dbo].[PaymentOthersAgentToAgent]
           ([FromAgency]
		   ,[ToAgency]
		   ,[Date]
           ,[Usd]
		   ,[StatusId]
           ,[CreationDate]
		   ,[CreatedBy]
		   ,[Note],
		   [CheckNumber],
	[CheckDate],
	[BankAccountId],
	[CardBankId] ,
	[AgencyId],
	[MoneyOrderNumber] ,
	[AchDate],
	[ProviderCommissionPaymentTypeId])
     VALUES
           (@AgencyFromId
		   ,@AgencyToId
           ,@Date
           ,@Usd
		   ,1
           ,@CreationDate
		   ,@CreatedBy
		   ,@Note
		   ,@CheckNumber,
	@CheckDate,
	@BankAccountId,
	@CardBankId ,
	@AgencyId,
	@MoneyOrderNumber ,
	@AchDate,
	@ProviderCommissionPaymentTypeId)

		   SELECT @@IDENTITY




     END;
GO