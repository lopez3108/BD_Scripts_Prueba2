SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesProvisional] @ProvisionalReceiptId INT = NULL
AS
     BEGIN
         SELECT ProvisionalNotesId,
                ProvisionalReceiptId,
                Note,
                CreationDate,
                CreatedBy,
                Name AS CreatedByName
         FROM [dbo].[ProvisionalNote]
              left JOIN Users ON [dbo].[ProvisionalNote].CreatedBy = Users.UserId
         WHERE ProvisionalReceiptId = @ProvisionalReceiptId
         ORDER BY CreationDate;
     END;
GO