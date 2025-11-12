SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--2024-04-11 JF/ 5789: Adjust vehicle services alert PENDING SHIPPING RETURNS

-- =============================================
-- Author:      JF
-- Create date: 13/07/2024 6:27 p. m.
-- Database:    copiaDevtest
-- Description: task 5916 Aplicar fee a los para los VEHICLE SERVICES RETURNED
-- =============================================



CREATE   PROCEDURE [dbo].[sp_GetReturnsELSList]
 (

      @AgencyId INT = NULL,
      @ProviderId int = NULL,
      @StatusId INT = NULL,
      @FromDate DATETIME = NULL,
      @ToDate DATETIME = NULL,
      @PackageNumber VARCHAR(30) = NULL,
      @UserId INT = NULL,
      @IsManager AS BIT = NULL,
      @UserLoginId INT = NULL

    )
AS 

BEGIN

SELECT 
dbo.ReturnsELS.ReturnsELSId, 
dbo.ReturnsELS.InventoryELSId, 
dbo.ReturnsELS.Number AS Quantity, 
cast(dbo.ReturnsELS.Number as NUMERIC) as Number,
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
dbo.ReturnsELS.ShippingDate,
dbo.ReturnsELS.CashierId,
 (CASE
        WHEN ReturnsELS.ReturnType = 1 THEN 'DAMAGED'
        ELSE 'INVENTORY RETURN'
      END) ReturnTypeSaved,
ReturnsELS.ReturnType,

      ReturnsELS.Fee

FROM     dbo.ReturnsELS INNER JOIN
                  dbo.Agencies ON dbo.ReturnsELS.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                  dbo.InventoryELS ON dbo.ReturnsELS.InventoryELSId = dbo.InventoryELS.InventoryELSId INNER JOIN
                  dbo.Users ON dbo.ReturnsELS.CreatedBy = dbo.Users.UserId INNER JOIN
                  dbo.ReturnELSStatus ON dbo.ReturnELSStatus.ReturnsELSStatusId = dbo.ReturnsELS.ReturnsELSStatusId INNER JOIN
                  dbo.Users AS Users_1 ON dbo.ReturnsELS.LastUpdatedBy = Users_1.UserId
  WHERE 
  ((@IsManager = 0 AND (dbo.ReturnsELS.[AgencyId] = @AgencyId OR @AgencyId IS NULL)) OR ( @IsManager = 1
                       AND ReturnsELS.AgencyId IN
        (
            SELECT AgencyId
            FROM AgenciesxUser
            WHERE UserId = @UserLoginId
        ) AND (ReturnsELS.AgencyId = @AgencyId OR @AgencyId IS NULL) )   )
  
  
  AND (dbo.ReturnsELS.CreatedBy = @UserId OR @UserId IS NULL) AND
  (@ProviderId IS NULL OR dbo.ReturnsELS.[InventoryELSId] = @ProviderId) AND
  (@StatusId IS NULL OR dbo.ReturnsELS.[ReturnsELSStatusId] = @StatusId) AND
  (@PackageNumber IS NULL OR dbo.ReturnsELS.PackageNumber = @PackageNumber) AND
  (@FromDate IS NULL OR CAST(dbo.ReturnsELS.CreatedOn as DATE) >= CAST(@FromDate as DATE)) AND
  (@ToDate IS NULL OR CAST(dbo.ReturnsELS.CreatedOn as DATE) <= CAST(@ToDate as DATE))
	END
GO