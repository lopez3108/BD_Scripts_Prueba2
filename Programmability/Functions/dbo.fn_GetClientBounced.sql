SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE   FUNCTION [dbo].[fn_GetClientBounced] 
(
	@ClientId int
)
RETURNS bit
AS
BEGIN

declare @result bit
IF(EXISTS(SELECT * FROM Checks WHERE ClientId = @ClientId))
BEGIN

set @result = 1

END
ELSE
BEGIN

set @result = 0

END

RETURN @result

END
GO