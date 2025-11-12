SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetFraudAlertIsNotFraud]
@Account VARCHAR(50) = NULL,
@Maker VARCHAR(80) = NULL
AS 
BEGIN
	SELECT fa.Maker,fa.Account,fa.IsNotFraud FROM FraudAlert fa 
  JOIN CheckFraudExceptions cfe ON fa.Account = cfe.Account AND fa.Maker = cfe.Maker
  WHERE fa.Account = @Account AND fa.Maker = @Maker AND cfe.IsSafe = 1

END
GO