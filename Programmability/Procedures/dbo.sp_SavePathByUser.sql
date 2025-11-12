SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePathByUser]
(@PahtByUserId   INT            = NULL,
 @PathResource  VARCHAR(500),  
 @CreationDate   DATETIME = NULL,
 @RolesAllowed   VARCHAR(100) = NULL,
 @ParentId  INT     = NULL,
 @CreatedBy  INT     = NULL,
 @UpdatedBy   INT  = NULL,
 @UpdatedOn   DATETIME    = NULL,
 @IdCreated      INT OUTPUT
)
AS
     BEGIN
        IF(@PahtByUserId IS NULL OR @PahtByUserId <= 0)
             BEGIN
                 INSERT INTO [dbo].PathsByUsers
                 (PathResource,
                  CreationDate,
				  CreatedBy,
				  RolesAllowed,
				  ParentId                 
                 )
                 VALUES
                 (@PathResource ,   
					 @CreationDate ,
					 @CreatedBy,
					 @RolesAllowed,
					 @ParentId
                 );
				   SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].PathsByUsers
                   SET
                  PathResource = @PathResource,
				  RolesAllowed = @RolesAllowed,
                  UpdatedBy = @UpdatedBy, 
				  UpdatedOn = @UpdatedOn	
                 WHERE PahtByUserId = @PahtByUserId;
				   SET @IdCreated = @PahtByUserId;
         END;

		
     END;
GO