SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePaymentChecks]
@PaymentCheckId INT = NULL,
@AgencyId INT,
@Usd DECIMAL(18,2),
@Fee DECIMAL(18,2) =  NULL,
@ChecksCount INT,
@CreationDate DATETIME = NULL,
@CreatedBy INT = NULL,
@Date DATETIME = NULL,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@ProviderId INT = NULL,
@LotNumber		SMALLINT = NULL,
@UpdatedOn DATETIME = NULL,
@UpdatedBy INT = NULL
AS
     BEGIN



	
	 IF(@PaymentCheckId IS NULL)
	 BEGIN 
INSERT INTO [dbo].[PaymentChecks]
           ([AgencyId]
		   ,[Date]
           ,[Usd]
		   ,[NumberChecks]
		   ,[StatusId]
           ,[CreationDate]
		   ,[CreatedBy]
		   ,[FromDate]
		   ,[ToDate]
		   ,[ProviderId]
		   ,[Fee]
		   ,LotNumber)
     VALUES
           (@AgencyId
           ,@Date
           ,@Usd
		   ,@ChecksCount
		   ,1
           ,@CreationDate
		   ,@CreatedBy
		   ,@FromDate
		   ,@ToDate
		   ,@ProviderId
		   ,@Fee
		   ,@LotNumber)

		   SELECT @@IDENTITY
		      END
		   ELSE
		   BEGIN 
		   UPDATE [PaymentChecks] SET Usd = @Usd, NumberChecks = @ChecksCount, 
		   UpdatedOn = @UpdatedOn , UpdatedBy = @UpdatedBy,
		   Fee = @Fee,
		   ProviderId = (CASE WHEN @ProviderId <> NULL 
		   THEN @ProviderId 
		   ELSE
		   ProviderId
		   END),
		   AgencyId = (CASE WHEN  @AgencyId > 0
		   THEN @AgencyId
		   ELSE
		   AgencyId
		   END),
		   LotNumber = (CASE WHEN @LotNumber > 0
		   THEN @LotNumber 
		   ELSE
		   LotNumber
		   END)
		   WHERE PaymentCheckId = @PaymentCheckId
		   SELECT @PaymentCheckId;
		   END
		   


     END;
GO