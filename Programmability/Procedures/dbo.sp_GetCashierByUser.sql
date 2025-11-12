SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCashierByUser](@UserId INT)
AS
BEGIN
	SELECT c.CashierId ,
	c.IsComissions,
	c.ValidComissions
	FROM [dbo].[Cashiers] c(NOLOCK)
	INNER JOIN [dbo].[Users](NOLOCK) u ON c.UserId = u.UserId
	WHERE u.UserId = @UserId
END
GO