SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Returns the apartments notes
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetApartmentNotes]
@ApartmentId INT
		 AS
		  
BEGIN

SELECT        dbo.ApartmentNotes.ApartmentNotesId, dbo.ApartmentNotes.ApartmentId, dbo.ApartmentNotes.Note, dbo.ApartmentNotes.CreationDate, dbo.ApartmentNotes.CreatedBy, dbo.Users.Name AS CreatedByName
FROM            dbo.ApartmentNotes INNER JOIN
                         dbo.Users ON dbo.ApartmentNotes.CreatedBy = dbo.Users.UserId
						 WHERE dbo.ApartmentNotes.ApartmentId = @ApartmentId
						 ORDER BY dbo.ApartmentNotes.CreationDate ASC



END
GO