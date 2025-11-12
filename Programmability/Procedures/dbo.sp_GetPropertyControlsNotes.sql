SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertyControlsNotes] 
AS
     BEGIN


SELECT DISTINCT
dbo.PropertyControlsXProperty.Note
FROM            dbo.PropertyControlsXProperty
  ORDER BY dbo.PropertyControlsXProperty.Note ASC

END
GO