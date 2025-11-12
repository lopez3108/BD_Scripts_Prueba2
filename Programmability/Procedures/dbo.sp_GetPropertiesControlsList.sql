SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesControlsList] 
@ApartmentId INT = NULL,
@PropertiesId INT = NULL,
@Completed BIT = NULL,
@PropertyControlId INT = NULL,
 @CurrentDate DATETIME
AS
     BEGIN


SELECT
	dbo.PropertyControlsXProperty.PropertyControlsXPropertyId
   ,dbo.PropertyControlsXProperty.PropertyControlId
   ,dbo.PropertyControlsXProperty.PropertiesId
   ,dbo.PropertyControlsXProperty.ApartmentsId
   ,dbo.PropertyControlsXProperty.Date
   ,dbo.PropertyControlsXProperty.Note
   ,dbo.PropertyControlsXProperty.Completed
   ,CASE
		WHEN dbo.PropertyControlsXProperty.Completed = 1 THEN 'COMPLETED'
		ELSE 'PENDING'
	END AS Status
   ,dbo.PropertyControlsXProperty.CreationDate
   ,FORMAT(PropertyControlsXProperty.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat
   ,dbo.PropertyControlsXProperty.CreatedBy
   ,UPPER(dbo.Users.Name) AS UserName
   ,dbo.PropertyControls.Code
   ,dbo.PropertyControls.Name AS ControlName
   ,CASE
		WHEN ((CAST(dbo.PropertyControlsXProperty.CreationDate AS DATE) <> CAST(@CurrentDate AS DATE)) OR
			dbo.PropertyControlsXProperty.Completed = 1) THEN CAST(0 AS BIT)
		ELSE CAST(1 AS BIT)
	END AS CanEdit
   ,dbo.PropertyControlsXProperty.CompletedDate
   ,FORMAT(PropertyControlsXProperty.CompletedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CompletedDateFormat
   ,UPPER(Users_1.Name) AS CompletedBy
   ,dbo.PropertyControlsXProperty.ValidThrough
   ,FORMAT(PropertyControlsXProperty.ValidThrough, 'MM-dd-yyyy', 'en-US')  ValidThroughFormat
   ,Properties_1.Name
   ,dbo.Apartments.Number
   ,dbo.Properties.Name AS Expr1
   ,dbo.Apartments.Number
   ,CASE
		WHEN dbo.PropertyControlsXProperty.PropertiesId IS NULL THEN Properties.Name
		ELSE Properties_1.Name
	END AS PropertyName
   ,dbo.PropertyControlsXProperty.PropertiesId
FROM dbo.Properties
INNER JOIN dbo.Apartments
	ON dbo.Properties.PropertiesId = dbo.Apartments.PropertiesId
RIGHT OUTER JOIN dbo.PropertyControlsXProperty
INNER JOIN dbo.Users
	ON dbo.PropertyControlsXProperty.CreatedBy = dbo.Users.UserId
INNER JOIN dbo.PropertyControls
	ON dbo.PropertyControlsXProperty.PropertyControlId = dbo.PropertyControls.PropertyControlId
	ON dbo.Apartments.ApartmentsId = dbo.PropertyControlsXProperty.ApartmentsId
LEFT OUTER JOIN dbo.Properties AS Properties_1
	ON dbo.PropertyControlsXProperty.PropertiesId = Properties_1.PropertiesId
LEFT OUTER JOIN dbo.Users AS Users_1
	ON dbo.PropertyControlsXProperty.CompletedBy = Users_1.UserId
WHERE (@ApartmentId IS NULL
OR @ApartmentId = dbo.PropertyControlsXProperty.ApartmentsId)
AND ((@PropertiesId IS NULL
OR @PropertiesId = dbo.PropertyControlsXProperty.PropertiesId)
OR (@PropertiesId IS NULL
OR @PropertiesId = dbo.Apartments.PropertiesId))
AND (@Completed IS NULL
OR @Completed = [Completed])
AND (@PropertyControlId IS NULL
OR @PropertyControlId = dbo.PropertyControlsXProperty.PropertyControlId)
ORDER BY dbo.PropertyControlsXProperty.Date DESC

END
GO