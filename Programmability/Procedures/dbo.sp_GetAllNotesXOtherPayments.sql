SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesXOtherPayments] @PaymentOthersId INT, @Edit BIT = NULL
AS
  IF @Edit = 1
  BEGIN
    SELECT TOP 1
      UPPER(nxo.note) AS note
    FROM NotesXPaymentOthers nxo
    JOIN Users u
      ON u.UserId = nxo.CreatedBy
    WHERE nxo.PaymentOthersId = @PaymentOthersId
    ORDER BY nxo.creationDate ASC
  END
  ELSE
    SELECT
      UPPER(nxo.note) AS note
     ,nxo.creationDate AS creationDate
     ,nxo.NotesXPaymentOtherId
     ,UPPER(u.Name) AS createdByName
    FROM NotesXPaymentOthers nxo
    JOIN Users u
      ON u.UserId = nxo.CreatedBy
    WHERE nxo.PaymentOthersId = @PaymentOthersId
GO