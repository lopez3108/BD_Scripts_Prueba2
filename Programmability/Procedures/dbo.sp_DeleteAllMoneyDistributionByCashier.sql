SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllMoneyDistributionByCashier](@CashierId INT)
AS
     BEGIN

         DELETE MoneyDistribution
         WHERE CashierId = @CashierId;

		 SELECT @CashierId

    
	 END;
GO