SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSMSSent]
(@SMSSentId       INT          = NULL,
 @SMSCategoryId   INT          = NULL,
 @SMSCategoryCode VARCHAR(10)  = NULL,
 @Message         VARCHAR(500),
 @AgencyId        INT = NULL,
 @CreatedBy       INT          = NULL,
 @CreationDate    DATETIME,
 @Sent            BIT,
 @Telephone varchar (15) = null,
  @PropertyId        INT = NULL
)
AS
     BEGIN
         IF(@SMSCategoryId IS NULL
            OR @SMSCategoryId <= 0)
             BEGIN
                 SET @SMSCategoryId =
                 (
                     SELECT SMSCategoryId
                     FROM SMSCategories
                     WHERE Code = @SMSCategoryCode
                 );
         END;
         IF(@SMSSentId IS NULL)
             BEGIN
                 INSERT INTO [dbo].SMSSent
                 (SMSCategoryId,
                  Message,
                  Sent,
                  AgencyId,
                  CreatedBy,
                  CreationDate,
				  Telephone,
				  PropertyId
                 )
                 VALUES
                 (@SMSCategoryId,
                  @Message,
                  @Sent,
                  @AgencyId,
                  @CreatedBy,
                  @CreationDate,
				  @Telephone,
				  @PropertyId
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].SMSSent
                   SET
                       SMSCategoryId = @SMSCategoryId,
                       Message = @Message,
                       Sent = @Sent
					
                 WHERE SMSSentId = @SMSSentId;
         END;
     END;
GO