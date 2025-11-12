SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInventoryElsInAgency]
(
 @AgencyId      INT
 
)
AS
BEGIN

DECLARE @cashierId INT

SET @cashierId = (SELECT TOP 1 dbo.Cashiers.CashierId
FROM     dbo.AgenciesxUser INNER JOIN
                  dbo.Cashiers ON dbo.AgenciesxUser.UserId = dbo.Cashiers.UserId
				  WHERE dbo.AgenciesxUser.AgencyId = @AgencyId AND dbo.Cashiers.IsActive = 1)

INSERT INTO [dbo].[InventoryELSByAgency]
           ([AgencyId]
           ,[InventoryELSId]
           ,[InStock]
           ,[CashierId])
		   SELECT
		   @AgencyId,
		   InventoryELSId,
		   0,
		   CASE WHEN IsPersonalInventory = 1 THEN
		   @cashierId ELSE
		   NULL END FROM
		   dbo.InventoryELS
		   WHERE 
		   InventoryELSId NOT IN (
		   SELECT InventoryELSId FROM InventoryELSByAgency
		   WHERE InventoryELSByAgency.AgencyId = @AgencyId)
		   
   END
GO