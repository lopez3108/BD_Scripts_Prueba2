SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllInventoryEls](@Description VARCHAR(50) = NULL)
AS
     BEGIN
        SELECT 
		InventoryELSId, 
		Code, 
		Description, 
		AlertQuantity, 
		InventoryFormFileName, 
		InventoryFormRequired,
    AlertActive,
		CASE 
		WHEN InventoryFormFileName IS NULL THEN
		'NO'
		ELSE
		'YES'
		END as HasFormFile,
		CASE 
		WHEN InventoryFormRequired = 0 THEN
		'NO'
		ELSE
		'YES'
		END as IsFormRequiredText,
		IsPersonalInventory,
		CASE 
		WHEN InventoryFormFileName IS NULL THEN
		'NO'
		ELSE
		'YES'
		END as HasFormFile,
		CASE 
		WHEN IsPersonalInventory = 0 THEN
		'NO'
		ELSE
		'YES'
		END as IsPersonalInventoryText,
        	CASE 
		WHEN AlertActive = 0 THEN
		'NO'
		ELSE
		'YES'
		END as AlertActiveText

FROM     dbo.InventoryELS AS I
         
     END;
GO