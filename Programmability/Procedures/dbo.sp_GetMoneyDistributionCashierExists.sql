SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMoneyDistributionCashierExists] @CashierId INT
AS
     BEGIN
        

		 IF(EXISTS(SELECT TOP 1 MoneyDistributionId FROM [dbo].MoneyDistribution WHERE
			 CashierId = @CashierId))
			 BEGIN

			 SELECT CAST(1 as BIT) as Result

			 END
			 ELSE
			 BEGIN

			  SELECT CAST(0 as BIT) as Result

			 END



     END;
GO