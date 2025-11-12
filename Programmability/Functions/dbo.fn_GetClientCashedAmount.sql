SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetClientCashedAmount] 
(
	@ClientId int
)
RETURNS int
AS
BEGIN

declare @result decimal(18,2)
set @result = (SELECT SUM(Amount) FROM Checks WHERE ClientId = @ClientId)

RETURN @result

END
GO