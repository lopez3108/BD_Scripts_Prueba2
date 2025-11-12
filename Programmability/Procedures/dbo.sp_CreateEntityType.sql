SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateEntityType]
(@EntityTypeId INT = NULL,
@Description    VARCHAR(50)
)
AS
     BEGIN

         IF(@EntityTypeId IS NULL
            OR @EntityTypeId = 0)
             BEGIN
                 IF(EXISTS
                   (
                       SELECT [Description]
                       FROM EntityTypes
                       WHERE Description = @Description
                   ))
                     BEGIN
                         SELECT-1;
                 END
				 ELSE
				 BEGIN

				 INSERT INTO [dbo].[EntityTypes]
           ([Description])
     VALUES
           (@Description)

		   SELECT @@IDENTITY


				 END
                    
     END
	 ELSE
	 BEGIN


			 IF(EXISTS(SELECT * FROM [dbo].[EntityTypes] WHERE [Description] = @Description AND EntityTypeId <> @EntityTypeId))
			 BEGIN

			 SELECT -1


			 END
			 ELSE
			 BEGIN

UPDATE [dbo].[EntityTypes]
   SET [Description] = @Description
 WHERE EntityTypeId = @EntityTypeId


 SELECT @EntityTypeId

 END

END


	END
GO