SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCheckImages] @CheckId INT
AS
     BEGIN
         SELECT CheckFront,
                CheckBack
         FROM Checks
         WHERE CheckId = @CheckId;
     END;
GO