SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 7/07/2024 7:05 p. m.
-- Database:    copiaDevtest
-- Description: task 5918  Restringir serial numbers unique para los vehicle services returns
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetSerialNumberRepeatedByProviderAndAgency] (@inventoryELSId INT, @serialNumber VARCHAR(15), @agencyId INT)
AS
BEGIN

  SELECT TOP 1
    re.ReturnsELSId
   ,ie.Description
   ,sx.SerialNumber

  FROM ReturnsELS re
  INNER JOIN SerialsXReturn sx
    ON re.ReturnsELSId = sx.ReturnsELSId
  INNER JOIN InventoryELS ie
    ON re.InventoryELSId = ie.InventoryELSId
  WHERE re.AgencyId = @agencyId
  AND re.InventoryELSId = @inventoryELSId
  AND sx.SerialNumber = @serialNumber


END;

GO