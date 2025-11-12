SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteReturnsELS]
 (
 @ReturnsELSId int,
 @AgencyId int,
 @Number int

    )
AS 

BEGIN

declare @providerId INT
set @providerId = (SELECT TOP 1 InventoryELSId FROM ReturnsELS WHERE ReturnsELSId = @ReturnsELSId)

declare @inventoryId INT
set @inventoryId = (SELECT TOP 1 InventoryELSByAgencyId FROM InventoryELSByAgency 
WHERE InventoryELSId = @providerId AND AgencyId = @AgencyId)

UPDATE [dbo].[InventoryELSByAgency]
   SET [InStock] = [InStock] +  @Number
 WHERE InventoryELSByAgencyId = @inventoryId

 DELETE [dbo].[ReturnsELS] WHERE ReturnsELSId = @ReturnsELSId

 SELECT @inventoryId


	END


GO