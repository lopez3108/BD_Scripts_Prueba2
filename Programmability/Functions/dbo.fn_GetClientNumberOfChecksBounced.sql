SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
CREATE FUNCTION [dbo].[fn_GetClientNumberOfChecksBounced](@ClientId INT)
RETURNS INT
AS
     BEGIN
         DECLARE @result INT;
         SET @result =
         (
             SELECT COUNT(*)
             FROM Checks
             WHERE ClientId = @ClientId
         );
         RETURN @result;
     END;
GO