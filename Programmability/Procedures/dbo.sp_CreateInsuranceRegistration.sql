SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--10-10-2024 Jt/6085 Add  commissions cashiers for Insuranceregistration

-- 2024-08-31 DJ/6016: Creates an insurance registration

-- =============================================
-- Author:      JF
-- Create date: 7/10/2024 4:39 p. m.
-- Database:    developing
-- Description: task : Validar teléfono cliente
-- =============================================

-- 2024-11-25 DJ/6016: Agregar nuevo tipo de pago(cardpayments) para los insurance del daily
-- 2024-12-02 DJ/6213: Insurance - lógica incorrecta al editar o eliminar un movimiento durante el día de su creación
-- 2025-02-12 DJ/6345: Pagar automáticamente movimiento hechos con card customer
-- 2025-03-12 DJ/6391: Validación Automática de Transacciones con Balance en 0.00


CREATE PROCEDURE [dbo].[sp_CreateInsuranceRegistration] @InsuranceRegistrationId INT = NULL,
@ProviderId INT,
@ClientName VARCHAR(70),
@ClientTelephone VARCHAR(10),
@USD DECIMAL(18, 2),
@CreatedBy INT,
@CreationDate DATETIME,
@LastUpdatedOn DATETIME,
@LastUpdatedBy INT,
@CreatedInAgencyId INT,
@Cash DECIMAL(18, 2) = NULL,
@RegistrationReleaseSOSFee DECIMAL(18, 2),
@CardFee DECIMAL(18, 2) = NULL,
@TelIsCheck BIT = NULL,
@CashierCommission DECIMAL(18, 2) = NULL,
@PaymentType VARCHAR(50)


AS

BEGIN

  DECLARE @paymentStatus INT
         ,@commissionStatus INT
		 ,@currentPaymentStatusCode VARCHAR(5)
		 ,@paymentTypeCode VARCHAR(4)
		 ,@adjustmentCard DECIMAL(18,2)

		 IF (@InsuranceRegistrationId IS NOT NULL)
		 BEGIN

		 SET @currentPaymentStatusCode = (SELECT TOP 1 Code FROM dbo.InsurancePolicyStatus i
		WHERE i.InsurancePolicyStatusId = (SELECT TOP 1 p.PaymentStatusId FROM dbo.InsuranceRegistration p WHERE p.InsuranceRegistrationId = @InsuranceRegistrationId))


		 END

  SET @paymentStatus = (SELECT TOP 1
      InsurancePolicyStatusId
    FROM dbo.InsurancePolicyStatus i
    WHERE i.Code = 'C01')
  SET @commissionStatus = (SELECT TOP 1
      InsurancePolicyStatusId
    FROM dbo.InsurancePolicyStatus i
    WHERE i.Code = 'C01')

  IF (@USD = 0)
  BEGIN

    SET @paymentStatus = (SELECT TOP 1
        InsurancePolicyStatusId
      FROM dbo.InsurancePolicyStatus i
      WHERE i.Code = 'C02')

  END

  IF (@InsuranceRegistrationId IS NULL)
  BEGIN

  DECLARE @result DECIMAL(18,2)

    INSERT INTO [dbo].[InsuranceRegistration] ([ProviderId]
    , [ClientName]
    , [ClientTelephone]
    , [USD]
    , [CreatedBy]
    , [CreationDate]
    , [LastUpdatedOn]
    , [LastUpdatedBy]
    , [CreatedInAgencyId]
    , [Cash]
    , [RegistrationReleaseSOSFee]
    , PaymentStatusId
    , CommissionStatusId
    , CardFee
    , TelIsCheck
    ,CashierCommission
    ,[PaymentType])
      VALUES (@ProviderId, @ClientName, @ClientTelephone, @USD, @CreatedBy, @CreationDate, @LastUpdatedOn, @LastUpdatedBy, @CreatedInAgencyId, @Cash, @RegistrationReleaseSOSFee, @paymentStatus, @commissionStatus, @CardFee, @TelIsCheck,@CashierCommission,@PaymentType)

	  SET @result = @@IDENTITY
    
	  	-- 6345

		SET @paymentTypeCode = (SELECT TOP 1 PaymentType FROM dbo.InsuranceRegistration i WHERE i.InsuranceRegistrationId = @result)

		
		SET @adjustmentCard = [dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, @result)

		IF(@adjustmentCard = 0)
		BEGIN

		DECLARE @paymentStatusId INT
		SET @paymentStatusId = (select top 1 InsurancePolicyStatusId from dbo.InsurancePolicyStatus i WHERE i.Code = 'C02') --PAID

		UPDATE dbo.InsuranceRegistration SET 
		PaymentStatusId = @paymentStatusId,
		ValidatedBy = @CreatedBy,
		ValidatedOn = @CreationDate,
		ValidatedAgencyId = @CreatedInAgencyId
		WHERE InsuranceRegistrationId = @result

		END

		SELECT @result


  END
  ELSE
  BEGIN


    UPDATE [dbo].[InsuranceRegistration]
    SET [ProviderId] = @ProviderId
       ,[ClientName] = @ClientName
       ,[ClientTelephone] = @ClientTelephone
       ,[USD] = @USD
       ,[LastUpdatedOn] = @LastUpdatedOn
       ,[LastUpdatedBy] = @LastUpdatedBy
       ,[Cash] = @Cash
       ,[RegistrationReleaseSOSFee] = @RegistrationReleaseSOSFee
       ,[PaymentStatusId] = @paymentStatus
       ,[CommissionStatusId] = @commissionStatus
       ,[CardFee] = @CardFee
       ,[TelIsCheck] = @TelIsCheck
       ,PaymentType = @PaymentType
	   ,ValidatedBy = NULL
	   ,ValidatedOn = NULL
	   ,ValidatedAgencyId = NULL
    WHERE [InsuranceRegistrationId] = @InsuranceRegistrationId

	-- 6345

		SET @paymentTypeCode = (SELECT TOP 1 PaymentType FROM dbo.InsuranceRegistration i WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

		IF (@paymentTypeCode = 'C02')
		BEGIN

		SET @adjustmentCard = [dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, @InsuranceRegistrationId)

		IF(@adjustmentCard = 0)
		BEGIN

		SET @paymentStatusId = (select top 1 InsurancePolicyStatusId from dbo.InsurancePolicyStatus i WHERE i.Code = 'C02') --PAID

		UPDATE dbo.InsuranceRegistration SET 
		PaymentStatusId = @paymentStatusId,
		ValidatedBy = @LastUpdatedBy,
		ValidatedOn = @LastUpdatedOn,
		ValidatedAgencyId = @CreatedInAgencyId
		WHERE InsuranceRegistrationId = @InsuranceRegistrationId

		END

		END

    SELECT
      @InsuranceRegistrationId


  END


END







GO