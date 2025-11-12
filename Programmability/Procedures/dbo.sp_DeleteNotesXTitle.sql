SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteNotesXTitle](@TitleId INT)
AS
     BEGIN
         DELETE N
         FROM dbo.NotesXTitles N
         WHERE N.TitleId = @TitleId;
     END;


GO