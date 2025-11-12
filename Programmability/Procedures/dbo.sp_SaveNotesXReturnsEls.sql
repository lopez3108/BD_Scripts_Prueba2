SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by LF/26-06-2025 task 6634 Add ReturnsELS notes
CREATE PROCEDURE [dbo].[sp_SaveNotesXReturnsEls] @NotesXReturnsELSId INT = NULL,
@Note VARCHAR(2000),
@CreationDate DATETIME,
@CreatedBy INT,
@ReturnsELSId INT

AS

BEGIN

  SET NOCOUNT ON;

  INSERT INTO dbo.NotesXReturnsELS (
  Note,
  CreationDate,
  ReturnsELSId, CreatedBy)
    VALUES (@Note, @CreationDate, @ReturnsELSId,@CreatedBy);
END



GO