SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteMoneyDistribution](@MoneyDistributionId INT)
AS
     BEGIN

         DELETE FROM MoneyDistribution
         WHERE MoneyDistributionId = @MoneyDistributionId;

		 SELECT @MoneyDistributionId

    
	 END;
GO