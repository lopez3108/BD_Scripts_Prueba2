SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_SaveSmartSafeDeposit] 
	(
	 @SmartSafeDepositId			INT,
	 @ProviderId                    INT,
	 @TransactionId                 VARCHAR(15)    = NULL,
	 @Usd                           DECIMAL(18, 2) = NULL,
	 @Voucher						VARCHAR(50)    = NULL,
	 @UserId                        INT,
	 @AgencyId                      INT,
	 @CreationDate                  DATETIME	   = NULL,
	 @LastUpdatedBy					INT	           = NULL, 
	 @LastUpdatedOn					DATETIME	   = NULL
	)
AS
BEGIN
	IF(@SmartSafeDepositId > 0)
		BEGIN
			UPDATE dbo.SmartSafeDeposit
			SET			
			 TransactionId= @TransactionId,
			 Usd =  @Usd,
			 Voucher = @Voucher,
			 LastUpdatedBy = @LastUpdatedBy,
			 LastUpdatedOn = @LastUpdatedOn
			WHERE
				SmartSafeDepositId = @SmartSafeDepositId

			SELECT @SmartSafeDepositId
		END
	ELSE
		BEGIN
			INSERT INTO dbo.SmartSafeDeposit
			(
			 ProviderId,
			 TransactionId,
			 Usd,
			 Voucher,
			 UserId,
			 AgencyId,
			 CreationDate,
			 LastUpdatedBy,
			 LastUpdatedOn
			)
			VALUES
			(
			 @ProviderId,
			 @TransactionId,
			 @Usd,
			 @Voucher,
			 @UserId,
			 @AgencyId,
			 @CreationDate,
			 @LastUpdatedBy,
			 @LastUpdatedOn
			)	
			SELECT @@IDENTITY;
		END
	
END
GO