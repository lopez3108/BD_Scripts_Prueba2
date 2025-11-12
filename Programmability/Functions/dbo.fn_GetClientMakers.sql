SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
CREATE FUNCTION [dbo].[fn_GetClientMakers] 
(
	@ClientId int
)
RETURNS VARCHAR(200)
AS
BEGIN

DECLARE @Names VARCHAR(200) 
SELECT @Names = COALESCE(@Names + ', ', '') + Makers.Name 
FROM Checks INNER JOIN Makers ON
Makers.MakerId = Checks.Maker
WHERE ClientId = @ClientId

RETURN @Names

END

GO