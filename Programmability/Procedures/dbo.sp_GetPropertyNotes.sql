SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Retorna las notas de una propiedad
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPropertyNotes]
@PropertiesId INT
		 AS
		  
BEGIN

SELECT        dbo.PropertyNotes.PropertyNotesId, dbo.PropertyNotes.PropertiesId, dbo.PropertyNotes.Note, dbo.PropertyNotes.CreationDate, dbo.PropertyNotes.CreatedBy, dbo.Users.Name AS CreatedByName
FROM            dbo.PropertyNotes INNER JOIN
                         dbo.Users ON dbo.PropertyNotes.CreatedBy = dbo.Users.UserId
						 WHERE dbo.PropertyNotes.PropertiesId = @PropertiesId
						 ORDER BY dbo.PropertyNotes.CreationDate ASC


END
GO