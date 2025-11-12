SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReturnedCheckByNumber] @CheckNumber VARCHAR(15) = NULL, 
                                                    @Account     VARCHAR(50) = NULL
AS
    BEGIN
       

        SELECT *
        FROM dbo.ReturnedCheck
        WHERE(dbo.ReturnedCheck.CheckNumber = @CheckNumber
              OR @CheckNumber IS NULL)
             AND (dbo.ReturnedCheck.Account = @Account
                  OR @Account IS NULL);
    END;
GO