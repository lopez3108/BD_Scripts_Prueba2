SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetControlsByApartment] 
@ApartmentsId INT,
 @CurrentDate DATETIME
AS
     BEGIN


SELECT        dbo.PropertyControlsXProperty.PropertyControlsXPropertyId, dbo.PropertyControlsXProperty.PropertyControlId, dbo.PropertyControlsXProperty.PropertiesId, dbo.PropertyControlsXProperty.ApartmentsId, 
                         dbo.PropertyControlsXProperty.Date, dbo.PropertyControlsXProperty.Note, dbo.PropertyControlsXProperty.Completed, 
                         CASE WHEN dbo.PropertyControlsXProperty.Completed = 1 THEN 'COMPLETED' ELSE 'PENDING' END AS Status, dbo.PropertyControlsXProperty.CreationDate, dbo.PropertyControlsXProperty.CreatedBy, 
                         dbo.Users.Name AS UserName, dbo.PropertyControls.Code, dbo.PropertyControls.Name AS ControlName, CASE WHEN ((CAST(dbo.PropertyControlsXProperty.CreationDate AS DATE) <> CAST(@CurrentDate AS DATE)) OR
                         dbo.PropertyControlsXProperty.Completed = 1) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS CanEdit,
						 dbo.PropertyControlsXProperty.CompletedDate,Users_1.Name as CompletedBy,
						 dbo.PropertyControlsXProperty.ValidThrough
FROM            dbo.PropertyControlsXProperty INNER JOIN
                         dbo.Users ON dbo.PropertyControlsXProperty.CreatedBy = dbo.Users.UserId INNER JOIN
                         dbo.PropertyControls ON dbo.PropertyControlsXProperty.PropertyControlId = dbo.PropertyControls.PropertyControlId LEFT OUTER JOIN
                         dbo.Users AS Users_1 ON dbo.PropertyControlsXProperty.CompletedBy = Users_1.UserId
  WHERE [ApartmentsId] = @ApartmentsId
  ORDER BY dbo.PropertyControlsXProperty.Date DESC

END
GO