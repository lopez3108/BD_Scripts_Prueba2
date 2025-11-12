SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
CREATE FUNCTION [dbo].[fn_GetClientNumberOfChecks] 
(
	@ClientId int
)
RETURNS int
AS
BEGIN

declare @result int
set @result = (SELECT COUNT(*) FROM Checks WHERE ClientId = @ClientId)

RETURN @result

END
GO