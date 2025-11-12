SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateElsManualOther] @TitleId   INT,
                                                    @OtherId             INT          = NULL,
                                                    @FileIdNameOther VARCHAR(500)
AS
     BEGIN
         IF(@OtherId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ElsManualOther
                 (TitleId,                
                  FileIdNameOther
                 
                 )
                 VALUES
                 (@TitleId,
				 @FileIdNameOther                 
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ElsManualOther
                   SET
                       TitleId = @TitleId,
                       FileIdNameOther = @FileIdNameOther
                      
                 WHERE OtherId = @OtherId;
         END;
     END;
GO