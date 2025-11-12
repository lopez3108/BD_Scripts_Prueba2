SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesXTitlesByTitleId]  (@TitleId INT)

AS
     BEGIN
         SELECT nt.NotesXTitleId,
				nt.TitleId,
				nt.Note,
				nt.CreatedBy,
				nt.CreatedOn,
				u.Name AS NameCreatedBy
				

		 FROM NotesXTitles nt
			   INNER JOIN Titles t ON nt.TitleId = t.TitleId
			   INNER JOIN Users u ON  nt.CreatedBy  = u.UserId
				
		WHERE NT.TitleId =  @TitleId 
			  ORDER BY u.Name  DESC
		end	  
		 
GO