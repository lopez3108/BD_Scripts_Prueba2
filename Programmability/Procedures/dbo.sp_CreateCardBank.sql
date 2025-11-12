SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateCardBank] 
@CardNumber VARCHAR(4),
@BankAccountId VARCHAR(4),
 @CreatedBy INT,
@CreationDate DATETIME
AS
     BEGIN

	  IF(EXISTS(SELECT 1 FROM [CardBanks] WHERE CardNumber = @CardNumber))
	 BEGIN

	 SELECT -1

	 END

	 ELSE
	 BEGIN

INSERT INTO [dbo].[CardBanks]
           ([CardNumber],
		   CreatedBy,
		   CreationDate)
     VALUES
           (@CardNumber,
		   @CreatedBy,
		   @CreationDate)

		   declare @cardBankId INT
		   set @cardBankId = (SELECT @@IDENTITY)


		   INSERT INTO [dbo].[CardBanksXBankAccounts]
           ([BankAccountId]
           ,[CardBankId])
     VALUES
           (@BankAccountId
           ,@cardBankId)

		   SELECT @cardBankId

		   END


END
GO