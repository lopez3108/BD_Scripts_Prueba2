SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetLastRentPaymentByContract] (@ContractId INT)
AS

BEGIN

  SELECT TOP 1 ISNULL(Usd,0) as Usd,ISNULL(UsdPayment,0) as UsdPayment , ISNULL(FeeDue,0) as FeeDue, ISNULL(Cash,0) as Cash, ISNULL(MoveInFee,0) as MoveInFee, ISNULL(FinalBalance,0) as FinalBalance   FROM RentPayments WHERE ContractId = @ContractId
  ORDER By RentPaymentId DESC



END

GO