SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFinancingMessage]
(@FinancingMessageId INT          = NULL,
 @Title              VARCHAR(50),
 @SMSCategoryId      INT,
 @Message            VARCHAR(500)
)
AS
     BEGIN
         IF(@FinancingMessageId IS NULL)
             BEGIN
                 INSERT INTO [dbo].FinancingMessages
                 (Title,
                  Message,
                  SMSCategoryId
                 )
                 VALUES
                 (@Title,
                  @Message,
                  @SMSCategoryId
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].FinancingMessages
                   SET
                       Title = @Title,
                       Message = @Message,
                       SMSCategoryId = @SMSCategoryId
                 WHERE FinancingMessageId = @FinancingMessageId;
         END;
     END;
GO