SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNotesXPaymentBank]
(@NoteXPaymentBankId INT          = NULL, 
 @PaymentBankId   INT, 
 @Note                VARCHAR(2000), 
 @CreatedBy           INT, 
 @CreationDate        DATETIME
)
AS
    BEGIN
        IF(@NoteXPaymentBankId IS NULL)
            BEGIN
                INSERT INTO [dbo].PaymentBankNotes
                (CreatedBy, 
                 Note, 
                 CreationDate, 
                 PaymentBankId
                )
                VALUES
                (@CreatedBy, 
                 @Note, 
                 @CreationDate, 
                 @PaymentBankId
                );
            END;
    END;
GO