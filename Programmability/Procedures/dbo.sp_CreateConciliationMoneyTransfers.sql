SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConciliationMoneyTransfers] 
@ProviderId INT,
@AgencyId INT,
@BankAccountId INT,
@CreatedBy INT,
@Date DATETIME,
@IsCredit BIT,
@CreationDate DATETIME,
@Usd DECIMAL(18,2)
AS
     BEGIN

INSERT INTO [dbo].[ConciliationMoneyTransfers]
           ([ProviderId]
           ,[AgencyId]
           ,[BankAccountId]
           ,[Date]
           ,[IsCredit]
           ,[Usd]
           ,[CreatedBy]
           ,[CreationDate])
     VALUES
           (@ProviderId
           ,@AgencyId
           ,@BankAccountId
           ,@Date
           ,@IsCredit
           ,@Usd
           ,@CreatedBy
           ,@CreationDate)

		   SELECT @@IDENTITY

END
GO