SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateDocument]
(@DocumentId          INT          = NULL, 
 @DocumentByClientId  INT          = NULL, 
 @Doc1Front           VARCHAR(MAX) = NULL, 
 @Doc1Back            VARCHAR(MAX) = NULL, 
 @Doc1Type            INT          = NULL, 
 @Doc1Number          VARCHAR(80)  = NULL, 
 @Doc1Country         INT          = NULL, 
 @Doc1State           VARCHAR(50)  = NULL, 
 @Doc1Expire          DATETIME     = NULL, 
 --@Doc1Birth           DATETIME     = NULL, 
 @ExpireDoc1          BIT          = NULL, 
 @CreatedDate         DATETIME     = NULL, 
 @CreatedBy           INT          = NULL, 
 @DocumentStatusCode1 VARCHAR(10)  = NULL, 
 @UpdatedOn           DATETIME     = NULL, 
 @UpdatedBy           INT          = NULL, 
 @AgencyId            INT          = NULL
)
AS
    BEGIN
        DECLARE @DocumentStatusId1 INT= NULL;
        SET @DocumentStatusId1 =
        (
            SELECT DocumentStatusId
            FROM DocumentStatus
            WHERE Code = @DocumentStatusCode1
        );
        IF(@DocumentByClientId IS NULL)
            BEGIN
                INSERT INTO [dbo].[Documents]
                (DocumentId, 
                 [Doc1Front], 
                 [Doc1Back], 
                 [Doc1Type], 
                 [Doc1Number], 
                 [Doc1Country], 
                 [Doc1State], 
                 [Doc1Expire], 
                 --[Doc1Birth], 
                 ExpireDoc1, 
                 CreatedDate, 
                 CreatedBy, 
                 DocumentStatusId1, 
                 AgencyId
                )
                VALUES
                (@DocumentId, 
                 @Doc1Front, 
                 @Doc1Back, 
                 @Doc1Type, 
                 @Doc1Number, 
                 @Doc1Country, 
                 @Doc1State, 
                 @Doc1Expire, 
                 --@Doc1Birth, 
                 @ExpireDoc1, 
                 @CreatedDate, 
                 @CreatedBy, 
                 @DocumentStatusId1, 
                 @AgencyId
                );
                SELECT @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[Documents]
                  SET 
                      [Doc1Front] = CASE
                                        WHEN @Doc1Front IS NULL
                                        THEN [Doc1Front]
                                        ELSE @Doc1Front
                                    END, 
                      [Doc1Back] = CASE
                                       WHEN @Doc1Back IS NULL
                                       THEN [Doc1Back]
                                       ELSE @Doc1Back
                                   END, 
                      [Doc1Type] = @Doc1Type, 
                      [Doc1Number] = @Doc1Number, 
                      [Doc1Country] = @Doc1Country, 
                      [Doc1State] = @Doc1State, 
                      [Doc1Expire] = @Doc1Expire, 
                      --[Doc1Birth] = @Doc1Birth, 
                      ExpireDoc1 = @ExpireDoc1, 
                      DocumentStatusId1 = @DocumentStatusId1, 
                      UpdatedOn = @UpdatedOn, 
                      UpdatedBy = @UpdatedBy, 
                      AgencyId = @AgencyId
                WHERE DocumentByClientId = @DocumentByClientId;
                SELECT @DocumentByClientId;
            END;
    END;
GO