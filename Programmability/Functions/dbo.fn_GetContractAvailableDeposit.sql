SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetContractAvailableDeposit](@ContractId     INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
      
		declare @paid decimal(18,2)
		SET @paid =  (SELECT ISNULL(dbo.fn_GetDepositFinancingPaid(@ContractId),0)) 

		declare @expense decimal(18,2)
		SET @expense = ISNULL((SELECT SUM(DepositUsed) FROM [dbo].[PropertiesBillLabor] WHERE ContractId = @ContractId),0)

		RETURN @paid - @expense

     END;

GO