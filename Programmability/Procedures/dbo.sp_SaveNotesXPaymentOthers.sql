SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--date 26-06-2025 LF task 6620 Aumentar caracteres note others (DEBIT OR CREDIT)

CREATE PROCEDURE [dbo].[sp_SaveNotesXPaymentOthers] (@NoteXPaymentOtherId INT = NULL,
@PaymentOthersId INT,
@Note VARCHAR(2000),
@CreatedBy INT,
@CreationDate DATETIME)
AS
BEGIN
  IF (@NoteXPaymentOtherId IS NULL)
  BEGIN
    INSERT INTO [dbo].NotesXPaymentOthers (CreatedBy, Note, CreationDate, PaymentOthersId)
      VALUES (@CreatedBy, @Note, @CreationDate, @PaymentOthersId);
  END;
END;
GO