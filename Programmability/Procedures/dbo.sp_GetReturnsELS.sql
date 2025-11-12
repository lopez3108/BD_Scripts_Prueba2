SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--2024-05-02 JF/ 5831: Vehicle services screen settings returns

CREATE PROCEDURE [dbo].[sp_GetReturnsELS]
                    (
                        @ProviderId int = NULL,
                        @AgencyId int = NULL,
                        @StatusId INT = NULL
                    
                    )
AS 

BEGIN

SELECT
	dbo.ReturnsELS.ReturnsELSId
   ,dbo.ReturnsELS.InventoryELSId
   ,dbo.ReturnsELS.Number
   ,dbo.ReturnsELS.Reason
   ,dbo.ReturnsELS.AgencyId
   ,dbo.ReturnsELS.CreatedBy
   ,dbo.ReturnsELS.CreatedOn
   ,u.Name AS UpdatedBy
   ,FORMAT(dbo.ReturnsELS.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdatedOn
   ,FORMAT(ReturnsELS.CreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreatedOnFormat
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS Agency
   ,dbo.InventoryELS.Description
   ,dbo.Users.Name AS CreatedUser
   ,RT.Description AS Status
FROM dbo.ReturnsELS
INNER JOIN dbo.Agencies
	ON dbo.ReturnsELS.AgencyId = dbo.Agencies.AgencyId
INNER JOIN dbo.InventoryELS
	ON dbo.ReturnsELS.InventoryELSId = dbo.InventoryELS.InventoryELSId
INNER JOIN dbo.Users
	ON dbo.ReturnsELS.CreatedBy = dbo.Users.UserId
  INNER JOIN dbo.Users u
	ON dbo.ReturnsELS.LastUpdatedBy = u.UserId
INNER JOIN dbo.ReturnELSStatus RT
	ON ReturnsELS.ReturnsELSStatusId = RT.ReturnsELSStatusId
WHERE dbo.ReturnsELS.[AgencyId] =
CASE
	WHEN @AgencyId IS NULL THEN dbo.ReturnsELS.[AgencyId]
	ELSE @AgencyId
END
AND dbo.ReturnsELS.InventoryELSId =
CASE
	WHEN @ProviderId IS NULL THEN dbo.ReturnsELS.InventoryELSId
	ELSE @ProviderId
END
AND (dbo.ReturnsELS.ReturnsELSStatusId = @StatusId OR @StatusId IS NULL)


END
GO