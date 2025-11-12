SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateLawyerPayments]
 (
	  @LawyerPaymentId int = null,
	  @ReturnedCheckId int,
	  @ProviderCommissionPaymentTypeId int,
	  @Usd decimal(18,2),
	  @CheckNumber varchar(15) = null,
	  @CheckDate datetime = null,
	  @BankAccountId int = null,
	  @CardBankId int = null,
	  @AgencyId int = null,
	  @MoneyOrderNumber varchar(20) = null,
	  @AchDate datetime = null,
	  @CreationDate datetime,
	  @CreatedBy int
    )
AS 

BEGIN
IF(@AchDate IS NOT NULL AND CAST(@AchDate AS DATE) > CAST(@CreationDate AS DATE))
BEGIN

SELECT -2

END
ELSE IF(@CheckDate IS NOT NULL AND CAST(@CheckDate AS DATE) > CAST(@CreationDate AS DATE))
BEGIN

SELECT -3

END
ELSE

	IF(@LawyerPaymentId IS NULL)
	BEGIN




		INSERT INTO [dbo].[LawyerPayments]
		VALUES (@ReturnedCheckId,
		  @ProviderCommissionPaymentTypeId,
		  @Usd,
		  @CheckNumber,
		  @CheckDate,
		  @BankAccountId,
		  @CardBankId,
		  @AgencyId,
		  @MoneyOrderNumber,
		  @AchDate,
		  @CreationDate,
		  @CreatedBy,
      @CreationDate,
      @CreatedBy)

		SELECT @@IDENTITY

	END
	ELSE
	BEGIN


DECLARE @creationDateDB datetime
SET @creationDateDB = (SELECT TOP 1 CreationDate FROM LawyerPayments WHERE LawyerPaymentId = @LawyerPaymentId)

IF(CAST(@creationDateDB AS DATE) <> CAST(@CreationDate AS DATE))
BEGIN

SELECT -1

END
--ELSE IF(@AchDate IS NOT NULL AND CAST(@AchDate AS DATE) > CAST(@CreationDate AS DATE))
--BEGIN
--
--SELECT -2
--
--END
--ELSE IF(@CheckDate IS NOT NULL AND CAST(@CheckDate AS DATE) > CAST(@CreationDate AS DATE))
--BEGIN
--
--SELECT -3
--
--END
ELSE
BEGIN


		UPDATE [dbo].[LawyerPayments]
		SET ProviderCommissionPaymentTypeId = @ProviderCommissionPaymentTypeId,
		  Usd = @Usd,
		  CheckNumber = @CheckNumber,
		  CheckDate = @CheckDate,
		  BankAccountId = @BankAccountId,
		  CardBankId = @CardBankId,
		  AgencyId = @AgencyId,
		  MoneyOrderNumber = @MoneyOrderNumber,
		  AchDate = @AchDate,
      LastUpdatedOn = @CreationDate,
      LastUpdatedBy = @CreatedBy

		WHERE LawyerPaymentId = @LawyerPaymentId AND ReturnedCheckId = @ReturnedCheckId

		SELECT @LawyerPaymentId

END

	END

END



GO