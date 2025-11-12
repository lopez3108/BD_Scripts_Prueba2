SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by LF/26-06-2025 task 6634 Add ReturnsELS notes
CREATE PROCEDURE [dbo].[sp_GetAllNotesXReturnsELSId]
@ReturnsELSId INT = NULL  
AS
BEGIN
  SET NOCOUNT ON;
  

  SELECT
    NotesXReturnsELSId
   ,Note
   ,CreationDate
   ,ReturnsELSId
   ,u.Name CreatedByName
  FROM NotesXReturnsELS nr
  INNER JOIN Users u
    ON u.UserId = nr.CreatedBy
  WHERE nr.ReturnsELSId = @ReturnsELSId

END;

GO