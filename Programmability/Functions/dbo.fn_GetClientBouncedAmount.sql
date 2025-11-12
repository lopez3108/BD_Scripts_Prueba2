SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetClientBouncedAmount](@ClientId INT)
RETURNS INT
AS
     BEGIN
         DECLARE @result DECIMAL(18, 2);
         SET @result =
         (
             SELECT SUM(Amount)
             FROM Checks
             WHERE ClientId = @ClientId
         );
         RETURN @result;
     END;
GO