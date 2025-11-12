SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetFileNumberIdentity]
(@FileNumber VARCHAR(12) = NULL, 
 @Name       VARCHAR(80) = NULL,
 @MakerId INT = NULL

)
AS
    BEGIN
        SELECT MakerId
        FROM Makers r
        WHERE( r.MakerId != @MakerId OR @MakerId IS NULL )AND (r.FileNumber = @FileNumber
              OR @FileNumber IS NULL)
			 
             and ((SELECT [dbo].[removespecialcharatersinstring]( UPPER(r.Name))) =
			 (SELECT [dbo].[removespecialcharatersinstring]( UPPER(@Name))) 
                 OR @Name IS NULL); --5120 task se deben buscar las coincidencias sin tener en cuetna caracteres especiales ni espacios 


				
    END;

 --SELECT * FROM Makers WHERE MakerId = 1210 ORDER BY Name
 --UPDATE Makers SET Name = 'MC DONALD''''S' WHERE MakerId = 1210
GO