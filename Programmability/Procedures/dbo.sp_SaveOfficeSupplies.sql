SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- ===================================================
-- Author:		Diego León Acevedo Arenas
-- Create date: 2021-12-10
-- Description:	Guarda los datos de OfficeSupplies.
-- ===================================================

-- exec [dbo].[sp_SaveOfficeSupplies] @OfficeSupplieId = 1, @Name = 'Papel', @CreatedBy = 1, @CreationDate = GETDATE(), @LastUpdatedBy = 1, @LastUpdatedOn = GETDATE()   

CREATE   PROCEDURE [dbo].[sp_SaveOfficeSupplies]
	@OfficeSupplieId INT = NULL,
	@Name VARCHAR(100) = '',
	@CreatedBy INT = NULL,
	@CreationDate DATETIME = NULL,
	@LastUpdatedBy INT = NULL,
	@LastUpdatedOn DATETIME = NULL,
	@FileOfficeSupplies varchar(max) = null,
	@IsActive BIT = NULL,
	@IdCreated      INT OUTPUT
AS
	BEGIN
		SET NOCOUNT ON;

		IF(@OfficeSupplieId IS NULL)
			BEGIN
				INSERT INTO OfficeSupplies
					([Name],
					 CreatedBy,
					 CreationDate,
					 LastUpdatedBy,
					 LastUpdatedOn,
					 FileOfficeSupplies,
					 IsActive
					)
				VALUES
					(UPPER(@Name),
					 @CreatedBy,
					 @CreationDate,
					 @LastUpdatedBy,
					 @LastUpdatedOn,
					 @FileOfficeSupplies,
					 @IsActive
					)
					   SET @IdCreated = @@IDENTITY;
			END
		ELSE
			BEGIN
				UPDATE OfficeSupplies WITH (ROWLOCK)
				SET
					[Name] = UPPER(@Name),					
					LastUpdatedBy = @LastUpdatedBy,
					LastUpdatedOn = @LastUpdatedOn,
					FileOfficeSupplies=@FileOfficeSupplies,
					IsActive=@IsActive
				WHERE OfficeSupplieId = @OfficeSupplieId
				  SET @IdCreated = @OfficeSupplieId;

			END	

	END
GO