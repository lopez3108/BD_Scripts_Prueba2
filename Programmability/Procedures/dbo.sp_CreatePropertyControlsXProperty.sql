SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePropertyControlsXProperty] (@PropertyControlId INT,
@PropertiesId INT,
@CreationDate DATETIME,
@CreatedBy INT)


AS

BEGIN
  INSERT PropertyControlsXProperty (PropertyControlId, PropertiesId, ApartmentsId, Date, Note, Completed, CreationDate, CreatedBy, Pending, CompletedBy, CompletedDate, ValidThrough)
    VALUES (@PropertyControlId, @PropertiesId, NULL, @CreationDate, NULL, 0, @CreationDate, @CreatedBy, 1, NULL, NULL, NULL);
END;

GO