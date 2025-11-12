SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePaymentCash] @AgencyId     INT = NULL,
                                             @ProviderId   INT = NULL,
                                             @Usd          DECIMAL(18, 2),
                                             @CreationDate DATETIME,
                                             @CreatedBy    INT,
                                             @Date         DATETIME = NULL,
											 @FileImageName  VARCHAR(1000)  = NULL,
											 @Status    INT,
											 @PaymentCashId    INT =NULL,
											  @IdCreated      INT OUTPUT
AS
     BEGIN
	 IF(@PaymentCashId IS NULL)
      BEGIN
         INSERT INTO  [dbo].[PaymentCash]
         ([AgencyId],
          [ProviderId],
          [USD],
          [CreationDate],
          [CreatedBy],
          [Date],
		  FileImageName,
		  Status
         )
         VALUES
         (@AgencyId,
          @ProviderId,
          @Usd,
          @CreationDate,
          @CreatedBy,
          @Date,
		  @FileImageName,
		  @Status
         );
         SET @IdCreated = @@IDENTITY;
	 END;
	  ELSE
             BEGIN
			

                 UPDATE [dbo].[PaymentCash]
                   SET
					  CreationDate = @CreationDate,
					  AgencyId = @AgencyId,
					  ProviderId = @ProviderId ,
					  Status = @Status,
					  Usd = @Usd,
					  CreatedBy= @CreatedBy,                 
					  Date= @Date,
					  FileImageName= @FileImageName
					  
                 WHERE PaymentCashId = @PaymentCashId;
				   SET @IdCreated = @PaymentCashId;
				   
         END;
     END;
GO