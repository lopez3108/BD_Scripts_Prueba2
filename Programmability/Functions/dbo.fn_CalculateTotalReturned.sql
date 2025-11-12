SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create   FUNCTION [dbo].[fn_CalculateTotalReturned](@ReturnedCheckId INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
        
       
         DECLARE @total DECIMAL(18, 2);
         SET @total = (
         (
             SELECT(USD + Fee)
             FROM [dbo].[ReturnedCheck]
             WHERE ReturnedCheckId = @ReturnedCheckId
         ) + ISNULL(
         (
             SELECT SUM(Usd)
             FROM CourtPayment
             WHERE ReturnedCheckId = @ReturnedCheckId
         ), 0) + ISNULL(
         (
             SELECT SUM(Usd)
             FROM LawyerPayments
             WHERE ReturnedCheckId = @ReturnedCheckId
         ), 0));
        
         IF(@total < 0)
             BEGIN
                 SET @total = 0;
             END;
         RETURN ISNULL(@total, 0);
     END;
GO