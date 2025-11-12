SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-20 DJ/6020: Creates Insurance Ach payment
-- 2025-01-05 DJ/6329: Ajuste pagos ACH
-- 2025-03-12 DJ/6391: Validación Automática de Transacciones con Balance en 0.00
-- 2025-04-04 JF/6455: Corregir registro de last updated by y on

CREATE PROCEDURE [dbo].[sp_CreateInsuranceAchPayment] @InsuranceAchPaymentId INT = NULL,
@InsurancePolicyId INT = NULL,
@InsuranceMonthlyPaymentId INT = NULL,
@InsuranceRegistrationId INT = NULL,
@BankAccountId INT,
@AchDate DATETIME,
@Usd DECIMAL(18, 2),
@CreatedBy INT,
@CreationDate DATETIME,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@TypeId INT
AS
BEGIN

  DECLARE @result INT
         ,@currentPaidStatus INT
         ,@policyStatusPaid INT
         ,@insuranceAdjustment DECIMAL(18, 2)
         ,@paymentStatusId INT

  SET @policyStatusPaid = (SELECT TOP 1
      InsurancePolicyStatusId
    FROM InsurancePolicyStatus i
    WHERE i.Code = 'C02')

  IF (@InsurancePolicyId IS NOT NULL)
  BEGIN

    SET @currentPaidStatus = (SELECT TOP 1
        i.PaymentStatusId
      FROM dbo.InsurancePolicy i
      WHERE i.InsurancePolicyId = @InsurancePolicyId)

  END
  ELSE
  IF (@InsuranceMonthlyPaymentId IS NOT NULL)
  BEGIN

    SET @currentPaidStatus = (SELECT TOP 1
        i.PaymentStatusId
      FROM dbo.InsuranceMonthlyPayment i
      WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

  END
  ELSE
  IF (@InsuranceRegistrationId IS NOT NULL)
  BEGIN

    SET @currentPaidStatus = (SELECT TOP 1
        i.PaymentStatusId
      FROM dbo.InsuranceRegistration i
      WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

  END

  IF (@currentPaidStatus = @policyStatusPaid)
  BEGIN

    SELECT
      -2

  END
  ELSE
  BEGIN


    IF (@InsuranceAchPaymentId IS NULL)
    BEGIN

      INSERT INTO [dbo].[InsuranceAchPayment] ([BankAccountId]
      , [AchDate]
      , [USD]
      , [CreationDate]
      , [CreatedBy]
      , [InsurancePolicyId]
      , [InsuranceMonthlyPaymentId]
      , [InsuranceRegistrationId]
      , LastUpdatedBy
      , LastUpdatedOn
      , TypeId)
        VALUES (@BankAccountId, @AchDate, @Usd, @CreationDate, @CreatedBy, @InsurancePolicyId, @InsuranceMonthlyPaymentId, @InsuranceRegistrationId, @LastUpdatedBy, @LastUpdatedOn, @TypeId)

      SET @result = (SELECT
          @@IDENTITY)

    END
    ELSE
    BEGIN

      UPDATE dbo.InsuranceAchPayment
      SET USD = @Usd
         ,AchDate = @AchDate
         ,BankAccountId = @BankAccountId
         ,LastUpdatedBy = @LastUpdatedBy
         ,LastUpdatedOn = @LastUpdatedOn
         ,TypeId = @TypeId
      WHERE InsuranceAchPaymentId = @InsuranceAchPaymentId

      SET @result = (SELECT
          @InsuranceAchPaymentId)

    END

    DECLARE @insurancePaymentStatusId INT
    SET @insurancePaymentStatusId = (SELECT TOP 1
        i.InsurancePaymentTypeId
      FROM dbo.InsurancePaymentType i
      WHERE i.Code = 'C04')

    IF (@InsurancePolicyId IS NOT NULL)
    BEGIN
      UPDATE dbo.InsurancePolicy
      SET InsurancePaymentTypeId = @insurancePaymentStatusId
         ,ValidatedUSD = [dbo].[fn_CalculateInsuranceAchUsd](@InsurancePolicyId, NULL, NULL)
         ,LastUpdatedOn = @LastUpdatedOn
         ,LastUpdatedBy = @LastUpdatedBy

      WHERE InsurancePolicyId = @InsurancePolicyId
    END

    IF (@InsuranceMonthlyPaymentId IS NOT NULL)
    BEGIN
      UPDATE dbo.InsuranceMonthlyPayment
      SET InsurancePaymentTypeId = @insurancePaymentStatusId
         ,ValidatedUSD = [dbo].[fn_CalculateInsuranceAchUsd](NULL, @InsuranceMonthlyPaymentId, NULL)
         ,LastUpdatedOn = @LastUpdatedOn
         ,LastUpdatedBy = @LastUpdatedBy
      WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId
    END

    IF (@InsuranceRegistrationId IS NOT NULL)
    BEGIN
      UPDATE dbo.InsuranceRegistration
      SET InsurancePaymentTypeId = @insurancePaymentStatusId
         ,ValidatedUSD = [dbo].[fn_CalculateInsuranceAchUsd](NULL, NULL, @InsuranceRegistrationId)
         ,LastUpdatedOn = @LastUpdatedOn
         ,LastUpdatedBy = @LastUpdatedBy
      WHERE InsuranceRegistrationId = @InsuranceRegistrationId
    END

    -- 6391
    SET @insuranceAdjustment = [dbo].[fn_CalculateInsuranceAdjustment](@InsurancePolicyId, @InsuranceMonthlyPaymentId, @InsuranceRegistrationId)

    IF (@insuranceAdjustment = 0)
    BEGIN

      SET @paymentStatusId = (SELECT TOP 1
          InsurancePolicyStatusId
        FROM dbo.InsurancePolicyStatus i
        WHERE i.Code = 'C02') --PAID

      DECLARE @agencyId INT


      IF (@InsurancePolicyId IS NOT NULL)
      BEGIN

        SET @agencyId = (SELECT TOP 1
            i.CreatedInAgencyId
          FROM dbo.InsurancePolicy i
          WHERE i.InsurancePolicyId = @InsurancePolicyId)

        UPDATE dbo.InsurancePolicy
        SET PaymentStatusId = @paymentStatusId
           ,ValidatedBy = @CreatedBy
           ,ValidatedOn = @CreationDate
           ,ValidatedAgencyId = @agencyId
        WHERE InsurancePolicyId = @InsurancePolicyId
      END

      IF (@InsuranceMonthlyPaymentId IS NOT NULL)
      BEGIN

        SET @agencyId = (SELECT TOP 1
            i.CreatedInAgencyId
          FROM dbo.InsuranceMonthlyPayment i
          WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

        UPDATE dbo.InsuranceMonthlyPayment
        SET PaymentStatusId = @paymentStatusId
           ,ValidatedBy = @CreatedBy
           ,ValidatedOn = @CreationDate
           ,ValidatedAgencyId = @agencyId
        WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId
      END

      IF (@InsuranceRegistrationId IS NOT NULL)
      BEGIN

        SET @agencyId = (SELECT TOP 1
            i.CreatedInAgencyId
          FROM dbo.InsuranceRegistration i
          WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

        UPDATE dbo.InsuranceRegistration
        SET PaymentStatusId = @paymentStatusId
           ,ValidatedBy = @CreatedBy
           ,ValidatedOn = @CreationDate
           ,ValidatedAgencyId = @agencyId
        WHERE InsuranceRegistrationId = @InsuranceRegistrationId
      END

    END


    SELECT
      @result

  END

END
GO