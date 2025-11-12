SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesFinancing] @FinancingId INT = NULL
AS
     BEGIN
         SELECT FinancingNoteId,
                FinancingId,
                Note,
                CreationDate,
                CreatedBy,
                Name AS CreatedByName
         FROM [dbo].[FinancingNotes]
              INNER JOIN Users ON [dbo].[FinancingNotes].CreatedBy = Users.UserId
         WHERE FinancingId = @FinancingId
         ORDER BY CreationDate;
     END;
GO