SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNews]
(@NewsId   INT            = NULL,
 @Description  VARCHAR(400),
 @DocumentName  VARCHAR(400),    
 @CreationDate   DATETIME,
 @CreatedBy  INT     ,
 @IdCreated      INT OUTPUT
)
AS
     BEGIN
        IF(@NewsId IS NULL)
             BEGIN
                 INSERT INTO [dbo].News
                 (Description,
                  DocumentName,
                  CreationDate,
				  CreatedBy
                 
                 )
                 VALUES
                 (@Description ,
					 @DocumentName ,    
					 @CreationDate ,
					 @CreatedBy
                 );
				   SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].News
                   SET
                  Description = @Description,
                  DocumentName= @DocumentName
                  
                 WHERE NewsId = @NewsId;
				   SET @IdCreated = @NewsId;
         END;
     END;

GO