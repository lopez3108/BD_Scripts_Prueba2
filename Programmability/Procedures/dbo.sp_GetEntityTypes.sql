SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetEntityTypes]
(@EntityTypeId INT = NULL
)
AS
     BEGIN

       SELECT EntityTypeId, [Description] FROM EntityTypes
	   WHERE (@EntityTypeId IS NULL OR EntityTypeId = @EntityTypeId)
	   ORDER BY DESCRIPTION ASC

	END
GO