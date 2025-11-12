SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SetPasswordChange]
(@Code VARCHAR (10),
 @IsDefault  BIT
)
AS
     BEGIN
         UPDATE [dbo].PasswordChangeSettins
           SET
               IsDefault = 0;
         UPDATE [dbo].PasswordChangeSettins
           SET
               IsDefault = @IsDefault
         WHERE Code = @Code;
     END;
GO