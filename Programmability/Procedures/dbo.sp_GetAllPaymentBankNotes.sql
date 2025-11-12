SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPaymentBankNotes] @PaymentBankId INT = NULL
AS
    BEGIN
        SELECT NoteXPaymentBankId, 
               PaymentBankId, 
               Note, 
               CreationDate, 
               CreatedBy, 
              
               Users.Name AS CreatedByName
      FROM [dbo].PaymentBankNotes
             INNER JOIN Users ON [dbo].PaymentBankNotes.CreatedBy = Users.UserId

        WHERE PaymentBankId = @PaymentBankId
        ORDER BY CreationDate ASC;
    END;
GO