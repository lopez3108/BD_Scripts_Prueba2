SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-11 DJ/6034: Checks if insurance provider has related operations

CREATE PROCEDURE [dbo].[sp_DeleteProvider](@ProviderId INT)
AS
     BEGIN

	 DECLARE @result int
	 SET @result = 0


         DECLARE @code VARCHAR(10);
         SET @code =
         (
             SELECT TOP 1 dbo.ProviderTypes.Code
             FROM dbo.Providers
                  INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
             WHERE dbo.Providers.ProviderId = @ProviderId
         );

		  IF(@code = 'C02')
             BEGIN
                 
				 IF(EXISTS
                   (
                       SELECT dbo.MoneyTransferxAgencyNumbers.ProviderId
                       FROM dbo.MoneyDistribution
                            INNER JOIN dbo.MoneyTransferxAgencyNumbers ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
                       WHERE dbo.MoneyTransferxAgencyNumbers.ProviderId = @ProviderId
                   ))
				   BEGIN


				   set @result = -1

				   END


         END;
		 ELSE IF(@code = '26') --6036
             BEGIN

			 IF(EXISTS
                   (
                       SELECT i.InsurancePolicyId
                       FROM dbo.InsurancePolicy i
                       WHERE i.ProviderId = @ProviderId
                   ))
				   BEGIN


				   set @result = -1

				   END
				   ELSE IF(EXISTS
                   (
                       SELECT i.InsuranceRegistrationId
                       FROM dbo.InsuranceRegistration i
                       WHERE i.ProviderId = @ProviderId
                   ))
				   BEGIN


				   set @result = -1

				   END


			 END
		 
		 IF(@result >= 0)
		 BEGIN

		  DELETE Providers
         WHERE ProviderId = @ProviderId;
         
--       Se translado a un sp independiente 
--         IF(@code = 'C02')
--             BEGIN
--                 DELETE dbo.MoneyTransferxAgencyNumbers
--                 WHERE providerid = @ProviderId;
--
--				 DELETE SELECT * FROM dbo.MoneyTransferxAgencyInitialBalances
--                 WHERE providerid = @ProviderId;
--         END;

		 set @result = 1

		 END

		 SELECT @result
		 
     END;
GO