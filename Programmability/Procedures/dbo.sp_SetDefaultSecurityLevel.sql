SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SetDefaultSecurityLevel]
(@SecurityLevelId INT,
 @IsDefault       BIT
)
AS
     BEGIN
         UPDATE [dbo].SecurityLevel
           SET
               IsDefault = 0;
         UPDATE [dbo].SecurityLevel
           SET
               IsDefault = @IsDefault
         WHERE SecurityLevelId = @SecurityLevelId;
     END;
GO