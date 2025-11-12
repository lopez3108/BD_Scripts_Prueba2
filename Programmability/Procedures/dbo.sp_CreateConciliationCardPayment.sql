SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateConciliationCardPayment] 
@AgencyId INT,
@BankAccountId INT,
@CreatedBy INT,
@FromDate DATETIME,
@ToDate DATETIME,
@IsCredit BIT,
@CreationDate DATETIME,
@Mid varchar(20) = NULL
AS
     BEGIN

INSERT INTO [dbo].[ConciliationCardPayments]
           ([AgencyId]
           ,[BankAccountId]
           ,[FromDate]
		   ,[ToDate]
           ,[IsCredit]
           ,[CreatedBy]
           ,[CreationDate]
           ,MidSaved)
     VALUES
           (@AgencyId
           ,@BankAccountId
           ,@FromDate
		   ,@ToDate
           ,@IsCredit
           ,@CreatedBy
           ,@CreationDate, @Mid)

		   SELECT @@IDENTITY

END

GO