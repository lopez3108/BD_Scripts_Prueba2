SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveMakerValidation]
(@UrlXStateId        INT            = NULL, 
 @Entities          VARCHAR(500)= NULL,
 @Link          VARCHAR(500)= NULL
   

)
AS 

    BEGIN
      
         
                UPDATE [dbo].UrlsXState
                  SET 
                     
                      Entities = @Entities, 
                      Link = @Link
                   
                WHERE UrlXStateId = @UrlXStateId;
               
       
    END;
GO