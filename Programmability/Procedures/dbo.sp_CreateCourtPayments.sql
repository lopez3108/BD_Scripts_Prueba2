SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateCourtPayments]
(
  @CourtPaymentId int = NULL, @ReturnedCheckId int, @ProviderCommissionPaymentTypeId int, @Usd decimal(18, 2), @CheckNumber varchar(15) = NULL, @CheckDate datetime = NULL, @BankAccountId int = NULL, @CardBankId int = NULL, @AgencyId int = NULL, @MoneyOrderNumber varchar(20) = NULL, @AchDate datetime = NULL, @CreationDate datetime, @CreatedBy int

)
AS

BEGIN
IF (@AchDate IS NOT NULL AND
  CAST(@AchDate AS date) > CAST(@CreationDate AS date))
  BEGIN

    SELECT -2

  END
  ELSE
  IF (@CheckDate IS NOT NULL AND
  CAST(@CheckDate AS date) > CAST(@CreationDate AS date))
  BEGIN

    SELECT -3

  END
  ELSE

  IF (@CourtPaymentId IS NULL)
  BEGIN

    INSERT INTO [dbo].[CourtPayment]
    VALUES(@ReturnedCheckId, @ProviderCommissionPaymentTypeId, @Usd, @CheckNumber, @CheckDate, @BankAccountId, @CardBankId, @AgencyId, @MoneyOrderNumber, @AchDate, @CreationDate, @CreatedBy, @CreationDate, @CreatedBy)

    SELECT @@identity

  END
  ELSE
  BEGIN
      DECLARE @creationDateDB datetime
    SET @creationDateDB = (SELECT TOP 1 CreationDate
  FROM CourtPayment
  WHERE CourtPaymentId = @CourtPaymentId)

    IF (CAST(@creationDateDB AS date) <> CAST(@CreationDate AS date))
    BEGIN

      SELECT -1

    END
  
    ELSE
    BEGIN

    UPDATE [dbo].[CourtPayment]
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
    WHERE CourtPaymentId = @CourtPaymentId AND
          ReturnedCheckId = @ReturnedCheckId

    SELECT @CourtPaymentId

  END

  END
END


GO