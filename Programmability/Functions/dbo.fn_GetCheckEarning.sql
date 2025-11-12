SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetCheckEarning] 
(
	@CheckId int
)
RETURNS decimal(18,2)
AS
BEGIN

declare @result decimal(18,2)

set @result = (SELECT (((Amount * Fee / 100))) FROM Checks WHERE CHeckId = @CheckId)

RETURN @result

END
GO