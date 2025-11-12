SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetRentPendingFeeDue](
@ContractId   INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         


			declare @totltaDue decimal(18,2)
			set @totltaDue =  ISNULL((SELECT TOP 1 FeeDuePending FROm RentPayments WHERE ContractId = @ContractId ORDER BY RentPaymentId DESC),0)

			return  @totltaDue 


			

     END;
GO