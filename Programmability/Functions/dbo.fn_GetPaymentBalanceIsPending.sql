SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[fn_GetPaymentBalanceIsPending](@PaymentBalanceId     INT)
RETURNS BIT
AS
     BEGIN

		DECLARE @providerId INT, @year INT, @month INT, @agencyId INT, @result BIT, @deletedOn DATETIME

		SELECT 
		@providerId = pb.ProviderId, 
		@year = pb.Year, 
		@month = pb.Month, 
		@agencyId = pb.AgencyId,
		@deletedOn = pb.DeletedOn
		FROM PaymentBalance pb
		WHERE pb.PaymentBalanceId = @PaymentBalanceId
         
		 IF(@deletedOn IS NOT NULL)
		 BEGIN

		 SET @result = CAST(0 as BIT)

		 END
		 ELSE IF(EXISTS(SELECT pc.ProviderCommissionPaymentId FROM ProviderCommissionPayments pc
		 WHERE pc.ProviderId = @providerId AND
		 pc.Year = @year AND pc.Month = @month AND pc.AgencyId = @agencyId))
		 BEGIN

		 SET @result = CAST(0 as BIT)

		 END
		 ELSE 
		 BEGIN

		  SET @result = CAST(1 as BIT)

		 END

		 RETURN @result


     END;
GO