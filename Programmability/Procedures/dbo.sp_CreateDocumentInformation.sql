SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateDocumentInformation]
(@DocumentId  INT          = NULL, 
 @Name        VARCHAR(60)  = NULL, 
 @Telephone   VARCHAR(14), 
 @Note        VARCHAR(100) = NULL, 
 @CreatedDate DATETIME     = NULL, 
 @CreatedBy   INT          = NULL, 
 @UpdatedOn   DATETIME     = NULL, 
 @UpdatedBy   INT          = NULL, 
 @AgencyId    INT          = NULL, 
 @Doc1Birth   DATETIME     = NULL,
  @ValidatedBy         INT          = NULL, 
 @ValidatedOn         DATETIME     = NULL
)
AS
    BEGIN
        IF(@DocumentId IS NULL)
            BEGIN
                INSERT INTO [dbo].[DocumentInformation]
                (Name, 
                 Telephone, 
                 Note, 
                 CreatedDate, 
                 CreatedBy, 
                 AgencyId, 
                 [Doc1Birth]
                )
                VALUES
                (@Name, 
                 @Telephone, 
                 @Note, 
                 @CreatedDate, 
                 @CreatedBy, 
                 @AgencyId, 
                 @Doc1Birth
                );
                SELECT @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[DocumentInformation]
                  SET 
                      Name = @Name, 
                      Telephone = @Telephone, 
                      Note = @Note, 
                      UpdatedOn = @UpdatedOn, 
                      UpdatedBy = @UpdatedBy, 
                      AgencyId = @AgencyId, 
                      [Doc1Birth] = @Doc1Birth,
					     ValidatedBy = @ValidatedBy, 
                      ValidatedOn = @ValidatedOn
                WHERE DocumentId = @DocumentId;
                SELECT @DocumentId;
            END;
    END;
GO