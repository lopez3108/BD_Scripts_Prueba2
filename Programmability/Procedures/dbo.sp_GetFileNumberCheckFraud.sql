SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATED BY: JOHAN
--CREATED ON: 15-8-2023
-- BUSCA FILE NUMBER Y VALIDA QUE NO SE REPITA
CREATE PROCEDURE [dbo].[sp_GetFileNumberCheckFraud]
(@FileNumber VARCHAR(12) = NULL, 
@Maker VARCHAR(80) = NULL,
 @FraudId INT = NULL

)
AS
    BEGIN
        SELECT r.FraudId
        FROM FraudAlert  r
        WHERE( r.FraudId != @FraudId OR @FraudId IS NULL ) AND (r.FileNumber = @FileNumber
              OR @FileNumber IS NULL)
              
             and ((SELECT [dbo].[removespecialcharatersinstring]( UPPER(r.Maker))) =
			 (SELECT [dbo].[removespecialcharatersinstring]( UPPER(@Maker))) OR @Maker IS NULL);
			 
            

				
    END;



GO