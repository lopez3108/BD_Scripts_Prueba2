SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created: FELIPE
--CReated: 2-01-2024
--Task 5550
CREATE PROCEDURE [dbo].[sp_SaveCashAdvanceOrBack] 
	(
	 @CashAdvanceOrBackId			INT,
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
	IF(@CashAdvanceOrBackId > 0)
		BEGIN
			UPDATE dbo.CashAdvanceOrBack
			SET			
			 TransactionId= @TransactionId,
			 Usd =  @Usd,
			 Voucher = @Voucher,
			 LastUpdatedBy = @LastUpdatedBy,
			 LastUpdatedOn = @LastUpdatedOn
			WHERE
				CashAdvanceOrBackId = @CashAdvanceOrBackId

			SELECT @CashAdvanceOrBackId
		END
	ELSE
		BEGIN
			INSERT INTO dbo.CashAdvanceOrBack
			(
			 ProviderId,
			 TransactionId,
			 Usd,
			 Voucher,
			 CreatedBy,
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
			 @UserId,
			 @LastUpdatedOn
			)	
			SELECT @@IDENTITY;
		END
	
END

GO