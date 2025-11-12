SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAccountOwners]@Active BIT = NULL
AS
    BEGIN
        SELECT AccountOwnerId, 
               Code, 
               Name, 
               Active
        FROM dbo.AccountOwners
        WHERE(Active = @Active
              OR @Active IS NULL);
    END;
GO