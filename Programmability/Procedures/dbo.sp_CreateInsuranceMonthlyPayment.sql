SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--10-10-2024 Jt/6085 Add  commissions cashiers for InsuranceMonthlyPayment
-- 2024-10-07 JF/6116: Validar teléfono cliente
-- 2024-08-31 DJ/6016: Creates an insurance monthtly payment
-- 2024-11-25 DJ/6016: Agregar nuevo tipo de pago(cardpayments) para los insurance del daily
--26-11-2024 JT/6203 : Add news fields @CardFee DECIMAL(18, 2) = NULL, @PaymentType VARCHAR(50) = NULL,
-- 2024-12-02 DJ/6213: Insurance - lógica incorrecta al editar o eliminar un movimiento durante el día de su creación
-- 2024-12-08 JF/6243: Insurance - Add nuevo campo insurance
-- 2024-12-27 DJ/6266: Aplicar comisión provider a los insurance - NEW POLICY
-- 2024-12-30 DJ/6261: Aplicar comisión provider a los insurance - MONTHLY PAYMENTS
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B
-- 2025-01-28 DJ/6316: INSURANCE - NEW POLICY comportamiento errado y dificil de comprender con el adjustment
-- 2025-02-12 DJ/6345: Pagar automáticamente movimiento hechos con card customer
-- 2025-02-27 DJ/6365: Insurance quot
-- 2025-03-12 DJ/6391: Validación Automática de Transacciones con Balance en 0.00
-- 2025-08-14 JF/6719: Error al calcular el pago de las commissiones de los cajeros modulo insurance

CREATE PROCEDURE [dbo].[sp_CreateInsuranceMonthlyPayment] @InsuranceMonthlyPaymentId INT = NULL,
@InsurancePolicyId INT = NULL,
@ProviderId INT,
@InsuranceCompaniesId INT,
@ClientName VARCHAR(70),
@ClientTelephone VARCHAR(10),
@ExpirationDate DATETIME,
@PolicyNumber VARCHAR(20),
@PolicyTypeId INT,
@USD DECIMAL(18, 2),
@CreatedBy INT,
@CreationDate DATETIME,
@LastUpdatedOn DATETIME,
@LastUpdatedBy INT,
@CreatedInAgencyId INT,
@Cash DECIMAL(18, 2) = NULL,
@MonthlyPaymentServiceFee DECIMAL(18, 2),
@CardFee DECIMAL(18, 2) = NULL,
@TelIsCheck BIT = NULL,
@CashierCommission DECIMAL(18, 2) = NULL,
@PaymentType VARCHAR(50),
@TransactionId VARCHAR(36) = NULL,
@StatusCode VARCHAR(4),
@InsuranceCommissionTypeId INT,
@InsuranceCommissionTypeIdSaved INT,
@DOB DATETIME,
@IdCreated INT OUTPUT

AS

BEGIN

  DECLARE @paymentStatus INT
         ,@commissionStatus INT
         ,@monthlyPaymentIdResult INT
         ,@createdInsurancePolicyId INT = NULL
         ,@currentPaymentStatusCode VARCHAR(5)
         ,@TransactionIdExist INT
         ,@monthlyPaymentStatusId INT
		 ,@paymentTypeCode VARCHAR(4)
		 ,@adjustmentCard DECIMAL(18,2)
		 ,@paymentStatusId INT

  IF (@InsuranceMonthlyPaymentId IS NOT NULL)
  BEGIN

    SET @currentPaymentStatusCode = (SELECT TOP 1
        Code
      FROM dbo.InsurancePolicyStatus i
      WHERE i.InsurancePolicyStatusId = (SELECT TOP 1
          p.PaymentStatusId
        FROM dbo.InsuranceMonthlyPayment p
        WHERE p.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId))


  END

 SET @monthlyPaymentStatusId = (SELECT TOP 1
        MonthlyPaymentStatusId
      FROM dbo.MonthlyPaymentStatus mps
      WHERE mps.Code = @StatusCode)



SET @TransactionIdExist = (
    SELECT COUNT(1)
    FROM InsurancePolicy i
    WHERE i.TransactionId = @TransactionId
);

IF @TransactionIdExist > 0 BEGIN 
SET @IdCreated = -3

  SELECT
      @IdCreated	
END

ELSE
BEGIN


    SET @paymentStatus = (SELECT TOP 1
        InsurancePolicyStatusId
      FROM dbo.InsurancePolicyStatus i
      WHERE i.Code = 'C01')
    SET @commissionStatus = (SELECT TOP 1
        InsurancePolicyStatusId
      FROM dbo.InsurancePolicyStatus i
      WHERE i.Code = 'C01')

    DECLARE @PolicyIdResult INT
           ,@currentCreatedPolicyId INT = NULL

    SET @currentCreatedPolicyId = (SELECT TOP 1
        CreatedInsurancePolicyId
      FROM dbo.InsuranceMonthlyPayment i
      WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

	  DECLARE @currentProvider INT = NULL

    IF (@InsurancePolicyId IS NULL
      OR (@InsurancePolicyId IS NOT NULL
      AND @InsurancePolicyId = @currentCreatedPolicyId))
    BEGIN

	DECLARE @from BIT = CAST(1 as BIT)

	IF(@InsurancePolicyId IS NOT NULL)
	BEGIN
	SET @currentProvider = (SELECT TOP 1 ProviderId FROm dbo.InsurancePolicy i WHERE i.insurancepolicyid = @InsurancePolicyId)
	END

      EXEC [dbo].[sp_CreateInsurancePolicy] @InsurancePolicyId
                                           ,@ProviderId
                                           ,@InsuranceCompaniesId
                                           ,@ClientName
                                           ,@ClientTelephone
                                           ,@ExpirationDate
                                           ,@PolicyNumber
                                           ,@PolicyTypeId
                                           ,0
                                           ,@CreatedBy
                                           ,@CreationDate
                                           ,@LastUpdatedOn
                                           ,@LastUpdatedBy
                                           ,@CreatedInAgencyId
                                           ,NULL
                                           ,NULL
                                           ,@TelIsCheck
                                           ,1
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,@USD
										   ,0
										   ,@from
										   ,@DOB
										   ,NULL
                                           ,@PolicyIdResult OUT

      SET @createdInsurancePolicyId = @PolicyIdResult

    END
    ELSE
    BEGIN

      UPDATE dbo.InsurancePolicy
      SET ClientTelephone = @ClientTelephone
         ,LastUpdatedBy = @LastUpdatedBy
         ,LastUpdatedOn = @LastUpdatedOn
		 ,ExpirationDate = @ExpirationDate
		 ,DOB = @DOB
      WHERE InsurancePolicyId = @InsurancePolicyId

      SET @PolicyIdResult = @InsurancePolicyId

    END

    IF (@PolicyIdResult <= 0) -- Policy created/updated correctly
    BEGIN

      SET @monthlyPaymentIdResult = @PolicyIdResult -- Error during policy insert/updated
      SET @IdCreated = @PolicyIdResult

    END
    ELSE
    BEGIN

	DECLARE @commissionUSD DECIMAL(18,2), @currentCommissionType INT, @currenCommission DECIMAL(18,2)

      IF (@InsuranceMonthlyPaymentId IS NULL)
      BEGIN

	SET @commissionUSD = (SELECT ISNULL(i.USD,0) as CommissionUsd
 FROM dbo.InsuranceCommissionType c  LEFT JOIN
dbo.InsuranceCommissionTypeXProvider i ON c.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
AND i.ProviderId = @ProviderId 
WHERE c.InsuranceCommissionTypeId = @InsuranceCommissionTypeId)

        INSERT INTO [dbo].[InsuranceMonthlyPayment] ([USD]
        , [MonthlyPaymentServiceFee]
        , [CreatedBy]
        , [CreationDate]
        , [LastUpdatedOn]
        , [LastUpdatedBy]
        , [Cash]
        , [PaymentStatusId]
        , [CommissionStatusId]
        , [CardFee]
        , [InsurancePolicyId]
        , [CreatedInAgencyId]
        , [CreatedInsurancePolicyId]
        , [CashierCommission]
        , [PaymentType]
        , [TransactionId]
        , [MonthlyPaymentStatusId]
		,[InsuranceCommissionTypeId]
		,[CommissionUSD])
          VALUES (@USD, @MonthlyPaymentServiceFee, @CreatedBy, @CreationDate, @LastUpdatedOn, @LastUpdatedBy, @Cash, @paymentStatus, @commissionStatus,
          @CardFee, @PolicyIdResult, @CreatedInAgencyId, @createdInsurancePolicyId, @CashierCommission, @PaymentType,@TransactionId,@monthlyPaymentStatusId, @InsuranceCommissionTypeId, @commissionUSD)

        SET @IdCreated = @@IDENTITY

		-- 6345

		SET @paymentTypeCode = (SELECT TOP 1 PaymentType FROM dbo.InsuranceMonthlyPayment i WHERE i.InsuranceMonthlyPaymentId = @IdCreated)



		SET @adjustmentCard = [dbo].[fn_CalculateInsuranceAdjustment](NULL, @IdCreated, NULL)

		IF(@adjustmentCard = 0)
		BEGIN

		SET @paymentStatusId = (select top 1 InsurancePolicyStatusId from dbo.InsurancePolicyStatus i WHERE i.Code = 'C02') --PAID

		UPDATE dbo.InsuranceMonthlyPayment SET 
		PaymentStatusId = @paymentStatusId,
		ValidatedBy = @CreatedBy,
		ValidatedOn = @CreationDate,
		ValidatedAgencyId = @CreatedInAgencyId
		WHERE InsuranceMonthlyPaymentId = @IdCreated

		END





      END
      ELSE
      BEGIN

	  	SELECT @currentProvider = CASE WHEN @currentProvider IS NULL THEN p.ProviderId ELSE @currentProvider END, 
		@currentCommissionType = i.InsuranceCommissionTypeId, 
		@currenCommission = i.CommissionUsd 
		FROM dbo.InsuranceMonthlyPayment i
		INNER JOIN dbo.InsurancePolicy p ON p.InsurancePolicyId = i.InsurancePolicyId
	WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

	IF(@currentProvider = @ProviderId AND @currentCommissionType = @InsuranceCommissionTypeId)
	BEGIN

	SET @commissionUSD = @currenCommission

	END
	ELSE
	BEGIN

	SET @commissionUSD = (SELECT ISNULL(i.USD,0) as CommissionUsd
 FROM dbo.InsuranceCommissionType c  LEFT JOIN
dbo.InsuranceCommissionTypeXProvider i ON c.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
AND i.ProviderId = @ProviderId 
WHERE c.InsuranceCommissionTypeId = @InsuranceCommissionTypeId)

END


        UPDATE [dbo].[InsuranceMonthlyPayment]
        SET [USD] = @USD
           ,[MonthlyPaymentServiceFee] = @MonthlyPaymentServiceFee
           ,[CreatedBy] = @CreatedBy
           ,[CreationDate] = @CreationDate
           ,[LastUpdatedOn] = @LastUpdatedOn
           ,[LastUpdatedBy] = @LastUpdatedBy
           ,[Cash] = @Cash
           ,[PaymentStatusId] = @paymentStatus
           ,[CommissionStatusId] = @commissionStatus
           ,[CardFee] = @CardFee
           ,[InsurancePolicyId] = @PolicyIdResult
           ,[CreatedInsurancePolicyId] = @createdInsurancePolicyId
           ,PaymentType = @PaymentType
           ,TransactionId = @TransactionId
           ,MonthlyPaymentStatusId = @monthlyPaymentStatusId
		   ,[CommissionUSD] = @commissionUSD
		   ,[InsuranceCommissionTypeId] = @InsuranceCommissionTypeId
        ,[CashierCommission] = CASE 
                             WHEN @InsuranceCommissionTypeId <> @InsuranceCommissionTypeIdSaved 
                             THEN @CashierCommission
                             ELSE [CashierCommission] 
                          END
		   ,ValidatedBy = NULL
		   ,ValidatedOn = NULL
		   ,ValidatedAgencyId = null
        WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

		-- 6345

		SET @paymentTypeCode = (SELECT TOP 1 PaymentType FROM dbo.InsuranceMonthlyPayment i WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

	

		SET @adjustmentCard = [dbo].[fn_CalculateInsuranceAdjustment](NULL, @InsuranceMonthlyPaymentId, NULL)

		IF(@adjustmentCard = 0)
		BEGIN

		SET @paymentStatusId = (select top 1 InsurancePolicyStatusId from dbo.InsurancePolicyStatus i WHERE i.Code = 'C02') --PAID

		UPDATE dbo.InsuranceMonthlyPayment SET 
		PaymentStatusId = @paymentStatusId,
		ValidatedBy = @LastUpdatedBy,
		ValidatedOn = @LastUpdatedOn,
		ValidatedAgencyId = @CreatedInAgencyId
		WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

		END



        IF (@currentCreatedPolicyId IS NOT NULL
          AND @InsurancePolicyId <> @currentCreatedPolicyId)
        BEGIN

          DELETE dbo.InsurancePolicy
          WHERE InsurancePolicyId = @currentCreatedPolicyId

        END

        SET @IdCreated = @InsuranceMonthlyPaymentId

      END

    END


  END
END
GO