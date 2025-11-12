SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DelteCashier]
 (
	  @CashierId int

    )
AS 

BEGIN

declare @userId int
set @userId = (SELECT        Users.UserId
FROM            Cashiers INNER JOIN
                         Users ON Cashiers.UserId = Users.UserId
						 WHERE Cashiers.CashierId = @CashierId)

						 DELETE Cashiers WHERE CashierId = @CashierId

						 DELETE Users WHERE UserId = @userId 

						 SELECT 1

	END

GO