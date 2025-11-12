SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateInventoryEls]
(
@InventoryELSId INT = NULL,
@Code VARCHAR(5),
@Description VARCHAR(50),
@AlertQuantity INT,
@InventoryFormFileName VARCHAR(100) = NULL,
@InventoryFormRequired BIT,
@IsPersonalInventory BIT,
@AlertActive BIT
)
AS
     BEGIN


	 IF(@InventoryELSId IS NULL)
	 BEGIN

INSERT INTO [dbo].[InventoryELS]
           ([Code]
           ,[Description]
           ,[AlertQuantity]
           ,[InventoryFormFileName]
           ,[InventoryFormRequired]
		   ,[IsPersonalInventory]
       ,[AlertActive])
     VALUES
           (@Code
           ,@Description
           ,@AlertQuantity
           ,@InventoryFormFileName
           ,@InventoryFormRequired
		   ,@IsPersonalInventory
       ,@AlertActive)

		   SELECT @@IDENTITY


END
ELSE
BEGIN

UPDATE [dbo].[InventoryELS]
   SET [Code] = @Code
      ,[Description] = @Description
      ,[AlertQuantity] = @AlertQuantity
      ,[InventoryFormFileName] = @InventoryFormFileName
      ,[InventoryFormRequired] = @InventoryFormRequired
	  ,[IsPersonalInventory] = @IsPersonalInventory
    ,[AlertActive] = @AlertActive
 WHERE InventoryELSId = @InventoryELSId


 SELECT @InventoryELSId




END

     END;
GO