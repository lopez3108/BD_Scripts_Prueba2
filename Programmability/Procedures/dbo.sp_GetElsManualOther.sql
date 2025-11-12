SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_GetElsManualOther] @TitleId          INT
                                                
AS
     BEGIN
        
         SELECT *             
         FROM [dbo].ElsManualOther
         WHERE(TitleId = @TitleId)
            
     END;
GO