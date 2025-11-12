SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_AddStockInventoryElsPersonal](@InventoryELSId INT ,@AgencyId INT, @CashierId INT, @Units INT)
AS
     BEGIN
        
		IF(NOT EXISTS (SELECT * FROM dbo.InventoryELSByAgency WHERE AgencyId = @AgencyId AND CashierId = @CashierId AND 
		InventoryELSId = @InventoryELSId))
		BEGIN

INSERT INTO [dbo].[InventoryELSByAgency]
           ([AgencyId]
           ,[InventoryELSId]
           ,[InStock]
           ,[CashierId])
     VALUES
           (@AgencyId
           ,@InventoryELSId
           ,@Units
           ,@CashierId)

		   SELECT @@IDENTITY

		END
		ELSE
		BEGIN


UPDATE [dbo].[InventoryELSByAgency]
   SET 
      [InStock] = [InStock] + @Units
 WHERE AgencyId = @AgencyId AND CashierId = @CashierId AND 
		InventoryELSId = @InventoryELSId


		SELECT (SELECT TOP 1 InventoryELSByAgencyId FROM InventoryELSByAgency WHERE AgencyId = @AgencyId AND CashierId = @CashierId AND 
		InventoryELSId = @InventoryELSId )



		END









     END;
GO