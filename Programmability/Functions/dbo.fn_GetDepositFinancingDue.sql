SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetDepositFinancingDue](@ContractId   INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN

	 declare @paid DECIMAL(18,2)
	 set @paid = (SELECT ISNULL(dbo.fn_GetDepositFinancingPaid(@ContractId),0))

	 declare @deposit DECIMAL(18,2)
	 set @deposit = (
 
	 
	 SELECT Top 1 ISNULL(DownPayment,0)
             FROM Contract
             WHERE ContractId = @ContractId
	 
	 )

   


         RETURN
         (
             @deposit - @paid
            
         );
     END;

GO