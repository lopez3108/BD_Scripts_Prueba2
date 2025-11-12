SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetControlsByProperty] 
@PropertiesId INT,
 @CurrentDate DATETIME
AS
     BEGIN


SELECT        
pcp.PropertyControlsXPropertyId, 
pcp.PropertyControlId, 
pcp.PropertiesId, 
pcp.ApartmentsId, 
pcp.Date, 
pcp.Note, 
pcp.Completed, 
CASE WHEN pcp.Completed = 1 THEN 'COMPLETED' ELSE 'PENDING' END AS Status,
pcp.CreationDate,
pcp.CreatedBy, 
UPPER(dbo.Users.Name) AS UserName,
dbo.PropertyControls.Code, 
dbo.PropertyControls.Name AS ControlName, 
CASE WHEN ((CAST(pcp.CreationDate AS DATE) <> CAST(@CurrentDate AS DATE)) OR
                         pcp.Completed = 1) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS CanEdit,
pcp.CompletedDate,
UPPER(Users_1.Name) as CompletedBy,
pcp.ValidThrough
FROM            dbo.PropertyControlsXProperty pcp INNER JOIN
                         dbo.Users ON pcp.CreatedBy = dbo.Users.UserId INNER JOIN
                         dbo.PropertyControls ON pcp.PropertyControlId = dbo.PropertyControls.PropertyControlId LEFT OUTER JOIN
                         dbo.Users AS Users_1 ON pcp.CompletedBy = Users_1.UserId
  WHERE pcp.PropertiesId = @PropertiesId AND pcp.ApartmentsId IS NULL
  ORDER BY pcp.Date DESC

END
GO