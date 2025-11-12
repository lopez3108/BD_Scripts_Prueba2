SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePaymentBalance] @AgencyId     INT,
                                                @ProviderId   INT,
                                                @Usd          DECIMAL(18, 2),
                                                @CreationDate DATETIME,
                                                @CreatedBy    INT,
                                                @Date         DATETIME,
									   @FileBalance         varchar(MAX) = NULL,
									   @Cost DECIMAL(18, 2),
									   @Commission DECIMAL(18, 2),
									   @Year INT,
									   @Month INT
AS
     BEGIN

	 DECLARE @providerCode  VARCHAR(15)

	 SET @providerCode = (SELECT TOP 1 Code FROM ProviderCommissionPaymentTypes pr WHERE 
	 pr.ProviderCommissionPaymentTypeId = (SELECT TOP 1 c.ProviderCommissionPaymentTypeId FROM CommissionPaymentTypesXProviders c WHERE
	 c.ProviderId = @ProviderId))

	 IF(@providerCode <> 'CODE08')
	 BEGIN

	  SELECT -5


	 END
	 ELSE
	 BEGIN


	 IF(EXISTS(SELECT * FROM [dbo].[PaymentBalance] WHERE 
	 [AgencyId] = @AgencyId AND
	 [ProviderId] = @ProviderId AND
	  [Year] = @Year AND
	   [Month] = @Month AND 
	   DeletedOn IS NULL))
	   BEGIN

	   SELECT -1

	   END
	   ELSE
	   BEGIN


	   DECLARE @paymentDate DATE
	   SET @paymentDate = (SELECT DATEFROMPARTS (@Year, @Month, '01'))

	   DECLARE @dateOriginal DATE
	   SET @dateOriginal = (SELECT DATEFROMPARTS (DATEPART(year, @Date), DATEPART(MONTH, @Date), '01'))

	   IF(CAST(@dateOriginal as DATE) <= CAST(@paymentDate as DATE))
	   BEGIN

	   SELECT -2

	   END
	   ELSE IF(CAST(@Date as DATE) > CAST(@CreationDate as DATE))
	   BEGIN

	   SELECT -3

	   END
	   ELSE IF(EXISTS(SELECT * FROM ProviderCommissionPayments pc WHERE
	   pc.AgencyId = @AgencyId AND pc.ProviderId = @ProviderId AND pc.Month = @Month AND pc.Year = @Year))
	   BEGIN

	   SELECT -4

	   END
	   ELSE
	   BEGIN

	     INSERT INTO [dbo].[PaymentBalance]
         ([AgencyId],
          [ProviderId],
          [USD],
          [CreationDate],
          [CreatedBy],
          [Date],
		FileBalance,
		[Cost],
		[Commission],
		[Year],
		[Month]
         )
         VALUES
         (@AgencyId,
          @ProviderId,
          @Usd,
          @CreationDate,
          @CreatedBy,
          @Date,
		@FileBalance,
		@Cost,
		@Commission,
		@Year,
		@Month
         );
         SELECT @@IDENTITY;

		 END


	   END


	   END


       
     END;
GO