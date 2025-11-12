SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePaymentBanksToBank] 
@FromBankAccountId INT = NULL,
@ToBankAccountId INT = NULL,
@USD      DECIMAL(18,2),
@CreatedBy        INT,
@CreationDate       DATETIME,
@Date      DATETIME
AS
BEGIN

   INSERT INTO [dbo].[PaymentBanksToBanks]
           ([FromBankAccountId]
		   ,[ToBankAccountId]
           ,[Date]
           ,[USD]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@FromBankAccountId
		   ,@ToBankAccountId
           ,@Date
           ,@USD
           ,@CreationDate
           ,@CreatedBy)

		   SELECT @@IDENTITY



END
GO