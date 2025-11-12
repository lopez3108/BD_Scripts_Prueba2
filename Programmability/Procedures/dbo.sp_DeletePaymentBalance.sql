SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentBalance]

@PaymentBalanceId INT,
@DeletedOn DATETIME,
@DeletedBy INT

AS
     BEGIN


	 DECLARE @agencyId INT, @providerId INT, @year INT, @month INT, @typeId INT

	 SELECT TOP 1 
	 @agencyId = pb.AgencyId,
	  @providerId = pb.ProviderId,
	   @year = pb.Year,
	    @month = pb.Month
	 FROM [dbo].[PaymentBalance] pb WHERE pb.PaymentBalanceId = @PaymentBalanceId

	 SET @typeId = (SELECT TOP 1 pt.ProviderCommissionPaymentTypeId FROM ProviderCommissionPaymentTypes pt WHERE pt.Code = 'CODE08')

	 IF(EXISTS(select * from dbo.ProviderCommissionPayments pc WHERE
	 pc.AgencyId = @agencyId AND
	 pc.ProviderId = @providerId AND
	 pc.Year = @year AND
	 pc.Month = @month AND
	 pc.ProviderCommissionPaymentTypeId = @typeId))
	 BEGIN

	 DECLARE @commisionDate DATETIME, @commissionId INT

	 select TOP 1 @commissionId = pc.ProviderCommissionPaymentId, @commisionDate = CreationDate from 
	 dbo.ProviderCommissionPayments pc WHERE
	 pc.AgencyId = @agencyId AND
	 pc.ProviderId = @providerId AND
	 pc.Year = @year AND
	 pc.Month = @month AND
	 pc.ProviderCommissionPaymentTypeId = @typeId


	 IF(CAST(@DeletedOn as DATE) <> CAST(@commisionDate as DATE))
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

	 DELETE dbo.ProviderCommissionPayments
	 WHERE ProviderCommissionPaymentId = @commissionId

	 UPDATE [dbo].[PaymentBalance]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
 WHERE PaymentBalanceId = @PaymentBalanceId

 SELECT @PaymentBalanceId



	 END

	 END
	 ELSE
	 BEGIN

	 UPDATE [dbo].[PaymentBalance]
   SET 
      [DeletedOn] = @DeletedOn
      ,[DeletedBy] = @DeletedBy
 WHERE PaymentBalanceId = @PaymentBalanceId

 SELECT @PaymentBalanceId


	 END





     END;
GO