SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea los pago de cheque retornado
-- =============================================
-- =============================================
-- Author:      JF
-- Create date: 6/08/2024 9:00 p. m.
-- Database:    devCopySecure
-- Description: task 5989 Habilitar pagos a retornos para el admin
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateReturnPayment] @ReturnedCheckId INT,
@Usd DECIMAL(18, 2),
@CreationDate DATETIME,
@CreatedBy INT,
@ReturnPaymentModeId INT,
@AgencyId INT = NULL,
@CheckNumber VARCHAR(15) = NULL,
@CardPayment BIT,
@CardPaymentFee DECIMAL(18, 2) = NULL,
@Cash DECIMAL(18, 2),
@CheckDate DATETIME = NULL,
@ValidatedPostdatedChecksBy INT = NULL,
@BankAccountId INT = NULL,
@AchDate DATETIME = NULL
AS
BEGIN
  INSERT INTO [dbo].[ReturnPayments] ([ReturnedCheckId],
  [Usd],
  [CreationDate],
  [CreatedBy],
  [ReturnPaymentModeId],
  [AgencyId],
  [CheckNumber],
  CardPayment,
  CardPaymentFee,
  Cash,
  CheckDate,
  ValidatedPostdatedChecksBy,
  BankAccountId,
  AchDate)
    VALUES (@ReturnedCheckId, @Usd, @CreationDate, @CreatedBy, @ReturnPaymentModeId, @AgencyId, @CheckNumber, @CardPayment, @CardPaymentFee, @Cash, @CheckDate, @ValidatedPostdatedChecksBy,@BankAccountId,@AchDate);
  DECLARE @due DECIMAL(18, 2);
  SET @due = dbo.fn_CalculateDueReturned(@ReturnedCheckId);
  IF (@due = 0
    OR @due < 0)
  BEGIN
    UPDATE ReturnedCheck
    SET StatusId = (SELECT TOP 1
        ReturnStatusId
      FROM ReturnStatus
      WHERE Code = 'C02')
    WHERE ReturnedCheckId = @ReturnedCheckId;
  END;

  --  5271  
  BEGIN
    UPDATE ReturnedCheck
    SET LastModifiedDate = @CreationDate
       ,LastModifiedBy = @CreatedBy
    WHERE ReturnedCheckId = @ReturnedCheckId
  END

END;
GO