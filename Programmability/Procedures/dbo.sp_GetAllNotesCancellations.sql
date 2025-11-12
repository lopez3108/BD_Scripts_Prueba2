SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesCancellations] @CancellationId INT = NULL
AS
     BEGIN
         SELECT CancellationsNotesId,
                CancellationId,
                Note,
                CreationDate,
                CreatedBy,
                Name AS CreatedByName
         FROM [dbo].[CancellationNote]
              INNER JOIN Users ON [dbo].[CancellationNote].CreatedBy = Users.UserId
         WHERE CancellationId = @CancellationId
         ORDER BY CreationDate;
     END;
GO