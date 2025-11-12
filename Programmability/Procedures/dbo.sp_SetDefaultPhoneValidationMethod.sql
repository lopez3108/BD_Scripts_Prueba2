SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SetDefaultPhoneValidationMethod]
(@PhoneValidationMethodId INT,
 @IsDefault               BIT
)
AS
     BEGIN
         UPDATE [dbo].PhoneValidationMethods
           SET
               IsDefault = 0;
         UPDATE [dbo].PhoneValidationMethods
           SET
               IsDefault = @IsDefault
         WHERE PhoneValidationMethodId = @PhoneValidationMethodId;
     END;
GO