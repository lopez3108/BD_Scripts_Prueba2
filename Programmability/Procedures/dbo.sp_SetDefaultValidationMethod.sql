SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SetDefaultValidationMethod]
(@ValidationMethodId INT,
 @IsDefault       BIT
)
AS
     BEGIN
         UPDATE [dbo].ValidationMethods
           SET
               IsDefault = 0;
         UPDATE [dbo].ValidationMethods
           SET
               IsDefault = @IsDefault
         WHERE ValidationMethodId = @ValidationMethodId;
     END;
GO