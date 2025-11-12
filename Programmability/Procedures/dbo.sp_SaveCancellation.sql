SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 14/06/2024 2:55 p. m.
-- Database:    devtest
-- Description: task 5838 Enviar sms por default al momento de crear una cancelacción en pending (save ChooseMsg)
-- =============================================

--Last update by JT/08-05-2025 TASK 6506 ADD NEW FIELDS @ValidatedRefundManagerBy,@ValidatedRefundManagerOn ,@ValidatedRefundByTelClient


CREATE PROCEDURE [dbo].[sp_SaveCancellation] (@CancellationId INT = NULL,
@ClientName VARCHAR(200),
@ProviderCancelledId INT,
@ReceiptCancelledNumber VARCHAR(25) = NULL,
@Telephone VARCHAR(10),
@Email VARCHAR(50) = NULL,
@InitialStatusId INT,
@NoteXCancellationId INT,
@ProviderNewId INT = NULL,
@ReceiptNewNumber VARCHAR(25) = NULL,
@FinalStatusId INT = NULL,
@RefundDate DATETIME = NULL,
@CancellationDate DATETIME = NULL,
@RefundAmount DECIMAL(18, 2) = NULL,
@NewTransactionDate DATETIME = NULL,
@TotalTransaction DECIMAL(18, 2),
@Fee DECIMAL(18, 2),
@CreatedBy INT = NULL,
@ChangedBy INT = NULL,
@RefundFee BIT = NULL,
@AgencyId INT,
@CancellationTypeId INT = NULL,
@TelIsCheck BIT = NULL,
@LastUpdatedOn DATETIME,
@LastUpdatedBy INT,
@ValidatedBy INT = NULL,
@ValidatedOn DATETIME = NULL,
@ValidatedRefundManagerBy INT = NULL,
@ValidatedRefundManagerOn DATETIME = NULL,
@ValidatedRefundByTelClient BIT = NULL,
@ChooseMsg BIT = NULL,

@IdCreated INT OUTPUT)
AS
BEGIN
  --SET IDENTITY_INSERT [Cancellations] ON

  IF (@CancellationId IS NULL)
  BEGIN
    IF NOT EXISTS (SELECT TOP 1
          1
        FROM Cancellations
        WHERE AgencyId = @AgencyId
        AND ReceiptCancelledNumber = @ReceiptCancelledNumber
        AND ProviderCancelledId = @ProviderCancelledId)
    BEGIN
      INSERT INTO [dbo].[Cancellations] (ClientName,
      ProviderCancelledId,
      ReceiptCancelledNumber,
      InitialStatusId,
      ProviderNewId,
      ReceiptNewNumber,
      FinalStatusId,
      RefundDate,
      RefundAmount,
      NewTransactionDate,
      TotalTransaction,
      Fee,
      CreatedBy,
      ChangedBy,
      NoteXCancellationId,
      CancellationDate,
      AgencyId,
      Telephone,
      Email,
      RefundFee,
      CancellationTypeId,
      TelIsCheck,
      LastUpdatedOn,
      LastUpdatedBy,
      ValidatedBy,
      ValidatedOn,
      ChooseMsg, ValidatedRefundManagerBy, ValidatedRefundManagerOn, ValidatedRefundByTelClient)
        VALUES (@ClientName, @ProviderCancelledId, @ReceiptCancelledNumber, @InitialStatusId, @ProviderNewId, @ReceiptNewNumber, @FinalStatusId, @RefundDate, @RefundAmount, @NewTransactionDate, @TotalTransaction, @Fee, @CreatedBy, @ChangedBy, @NoteXCancellationId, @CancellationDate, @AgencyId, @Telephone, @Email, @RefundFee, @CancellationTypeId, @TelIsCheck, @LastUpdatedOn, @LastUpdatedBy, @ValidatedBy, @ValidatedOn, @ChooseMsg, @ValidatedRefundManagerBy, @ValidatedRefundManagerOn, @ValidatedRefundByTelClient);
      SET @IdCreated = @@IDENTITY;
    END;
    ELSE
    BEGIN
      SET @IdCreated = -999;
    END;
  END;
  ELSE
  BEGIN
    IF NOT EXISTS (SELECT TOP 1
          1
        FROM Cancellations
        WHERE AgencyId = @AgencyId
        AND ReceiptCancelledNumber = @ReceiptCancelledNumber
        AND CancellationId <> @CancellationId
        AND ProviderCancelledId = @ProviderCancelledId)
    BEGIN
      UPDATE [dbo].[Cancellations]
      SET ClientName = @ClientName
         ,ProviderCancelledId = @ProviderCancelledId
         ,ReceiptCancelledNumber = @ReceiptCancelledNumber
         ,InitialStatusId = @InitialStatusId
         ,ProviderNewId = @ProviderNewId
         ,ReceiptNewNumber = @ReceiptNewNumber
         ,FinalStatusId = @FinalStatusId
         ,RefundDate = @RefundDate
         ,RefundAmount = @RefundAmount
         ,NewTransactionDate = @NewTransactionDate
         ,TotalTransaction = @TotalTransaction
         ,Fee = @Fee
         ,CreatedBy = @CreatedBy
         ,ChangedBy = @ChangedBy
         ,NoteXCancellationId = @NoteXCancellationId
         ,CancellationDate = @CancellationDate
         ,Telephone = @Telephone
         ,Email = @Email
         ,RefundFee = @RefundFee
         ,CancellationTypeId = @CancellationTypeId
         ,TelIsCheck = @TelIsCheck
         ,LastUpdatedOn = @LastUpdatedOn
         ,LastUpdatedBy = @LastUpdatedBy
         ,AgencyId = @AgencyId
         ,ValidatedBy = @ValidatedBy
         ,ValidatedOn = @ValidatedOn
         ,ValidatedRefundManagerBy = @ValidatedRefundManagerBy
         ,ValidatedRefundManagerOn = @ValidatedRefundManagerOn
         ,ValidatedRefundByTelClient = @ValidatedRefundByTelClient
         ,ChooseMsg = @ChooseMsg
      WHERE CancellationId = @CancellationId;
      SET @IdCreated = @CancellationId;
    END;
    ELSE
    BEGIN
      SET @IdCreated = -999;
    END;
  END;
END;




GO