SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_DeleteNotePrincipalTitle](@TitleId INT)
AS
     BEGIN
         DELETE N
         FROM dbo.NotesXTitles N
         WHERE N.TitleId = @TitleId and IsPrincipalNote = 1;
     END;


GO