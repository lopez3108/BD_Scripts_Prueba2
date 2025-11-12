SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteEntityType]
(@EntityTypeId INT
)
AS
     BEGIN

       IF(EXISTS(SELECT * FROM Makers WHERE EntityTypeId = @EntityTypeId))
	   BEGIN 

	   SELECT -1

	   END
	   ELSE
	   BEGIN

	   DELETE EntityTypes WHERE EntityTypeId = @EntityTypeId

	   SELECT @EntityTypeId

	   END

	END
GO