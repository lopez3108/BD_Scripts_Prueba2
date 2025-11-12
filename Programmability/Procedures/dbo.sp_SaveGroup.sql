SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveGroup] 
@GroupId INT = NULL,
@Name VARCHAR(100),
@CreatedBy INT,
@CreatedOn DATETIME,
 @IdCreated      INT OUTPUT

AS
    select * from groups
     BEGIN
        IF(@GroupId IS NULL)
             BEGIN
                 INSERT INTO [dbo].Groups
                 (Name,
				 CreatedBy,
				 CreatedOn
                	  
				 
                 
                 )
                 VALUES
                 (@Name,
				 @CreatedBy,
				 @CreatedOn
		  
                 );
				   SET @IdCreated = @@IDENTITY;
				 
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].Groups
                   SET
                Name = @Name
				  --CreatedBy = @CreatedBy,
				  -- CreatedOn = @CreatedOn	
				 
                  
                 WHERE GroupId = @GroupId;
				  SET @IdCreated = @GroupId;
				   
         END;
     END;
GO