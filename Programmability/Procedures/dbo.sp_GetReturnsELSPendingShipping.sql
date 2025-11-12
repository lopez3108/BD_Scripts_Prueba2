SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReturnsELSPendingShipping]
 (

 @AgencyId int

    )
AS 

BEGIN

declare @statusId INT
SET @statusId = (SELECT TOP 1 ReturnsELSStatusId FROM ReturnELSStatus WHERE Code = 'C01')

SELECT 
dbo.ReturnsELS.ReturnsELSId, 
dbo.ReturnsELS.InventoryELSId, 
dbo.ReturnsELS.Number AS Quantity, 
dbo.ReturnsELS.Number,
dbo.ReturnsELS.Reason, 
dbo.ReturnsELS.AgencyId, 
dbo.ReturnsELS.CreatedBy AS UserCreatedId, 
dbo.ReturnsELS.CreatedOn AS CreationDate, 
dbo.ReturnsELS.LastUpdatedBy, 
dbo.ReturnsELS.LastUpdatedOn, 
dbo.ReturnsELS.PackageNumber, 
dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyName, 
dbo.InventoryELS.Description AS Provider, 
dbo.Users.Name AS CreatedBy, 
dbo.ReturnELSStatus.ReturnsELSStatusId, 
dbo.ReturnELSStatus.Code as StatusCode, 
dbo.ReturnELSStatus.Description AS Status,
Users_1.Name as LastUpdatedByName,
dbo.ReturnsELS.ShippingDate
FROM     dbo.ReturnsELS INNER JOIN
                  dbo.Agencies ON dbo.ReturnsELS.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                  dbo.InventoryELS ON dbo.ReturnsELS.InventoryELSId = dbo.InventoryELS.InventoryELSId INNER JOIN
                  dbo.Users ON dbo.ReturnsELS.CreatedBy = dbo.Users.UserId INNER JOIN
                  dbo.ReturnELSStatus ON dbo.ReturnELSStatus.ReturnsELSStatusId = dbo.ReturnsELS.ReturnsELSStatusId INNER JOIN
                  dbo.Users AS Users_1 ON dbo.ReturnsELS.LastUpdatedBy = Users_1.UserId
  WHERE dbo.ReturnsELS.ReturnsELSStatusId = @statusId AND
 dbo.ReturnsELS.AgencyId = @AgencyId
 
	END
GO