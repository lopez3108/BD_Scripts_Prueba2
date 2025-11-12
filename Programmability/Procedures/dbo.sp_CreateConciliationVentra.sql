SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConciliationVentra] 
@AgencyId INT,
@BankAccountId INT,
@CreatedBy INT,
@Date DATETIME,
@IsCredit BIT,
@CreationDate DATETIME,
@Usd DECIMAL(18,2)
AS
     BEGIN

INSERT INTO [dbo].[ConciliationVentras]
           ([AgencyId]
           ,[BankAccountId]
           ,[Date]
           ,[IsCredit]
           ,[Usd]
           ,[CreatedBy]
           ,[CreationDate])
     VALUES
           (@AgencyId
           ,@BankAccountId
           ,@Date
           ,@IsCredit
           ,@Usd
           ,@CreatedBy
           ,@CreationDate)

		   SELECT @@IDENTITY

END
GO