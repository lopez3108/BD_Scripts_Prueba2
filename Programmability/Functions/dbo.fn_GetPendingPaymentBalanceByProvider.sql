SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[fn_GetPendingPaymentBalanceByProvider](@ProviderId   INT)
RETURNS @result TABLE
(PaymentBalanceId INT
)
AS
     BEGIN
         
         INSERT INTO @result
         (PaymentBalanceId
         )
                SELECT PaymentBalanceId FROM PaymentBalance pb 
				WHERE pb.ProviderId = @ProviderId AND 
				pb.DeletedOn IS NULL AND
				dbo.fn_GetPaymentBalanceIsPending(pb.PaymentBalanceId) = CAST(1 as BIT)
                
         RETURN;
     END;
GO