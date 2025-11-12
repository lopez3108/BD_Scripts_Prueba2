SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCashFundsByCashier]
(
 @UserId         INT
)
AS
     BEGIN

	SELECT        dbo.Users.UserId, dbo.Cashiers.CashFund
FROM            dbo.Cashiers INNER JOIN
                         dbo.Users ON dbo.Cashiers.UserId = dbo.Users.UserId
						 WHERE dbo.Users.UserId = @UserId
		
		 END
GO