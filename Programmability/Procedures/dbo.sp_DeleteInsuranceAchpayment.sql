SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-26 DJ/6020: Deletes an insurance ach payment
-- 2025-02-10 JF/6281: Verificar regla de negocio para eliminar ACH payments insurance
-- 2025-04-15 JF/6455: Corregir registro de last updated by y on

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceAchpayment] @InsuranceAchPaymentId INT = NULL,
@Date DATETIME,
@UserId INT
AS
BEGIN

  DECLARE @InsurancePolicyId INT = NULL
         ,@InsuranceMonthlyPaymentId INT = NULL
         ,@InsuranceRegistrationId INT = NULL
         ,@currentPaidStatus INT
         ,@policyStatusPaid INT

  SET @policyStatusPaid = (SELECT TOP 1
      InsurancePolicyStatusId
    FROM InsurancePolicyStatus i
    WHERE i.Code = 'C02')

  SELECT
    @InsurancePolicyId = i.InsurancePolicyId
   ,@InsuranceMonthlyPaymentId = i.InsuranceMonthlyPaymentId
   ,@InsuranceRegistrationId = i.InsuranceRegistrationId
  FROM dbo.InsuranceAchPayment i
  WHERE i.InsuranceAchPaymentId = @InsuranceAchPaymentId

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
      -3

  END
  ELSE
  BEGIN

    DECLARE @creationDate DATETIME
           ,@createdBy INT
           ,@achCount INT
           ,@paymentStatusCode INT

    SELECT
      @creationDate = a.CreationDate
     ,@createdBy = a.CreatedBy
     ,@InsurancePolicyId = a.InsurancePolicyId
     ,@InsuranceMonthlyPaymentId = a.InsuranceMonthlyPaymentId
     ,@InsuranceRegistrationId = a.InsuranceRegistrationId
    FROM dbo.InsuranceAchPayment a
    WHERE a.InsurancePolicyId = @InsurancePolicyId

    -- Comentado por task 6281 Verificar regla de negocio para eliminar ACH payments insurance

    --	  IF(CAST(@Date as DATE) <> CAST(@creationDate as DATE) 
    --	  OR @UserId <> @createdBy)
    IF (@UserId <> @createdBy)

    BEGIN

      SELECT
        -1

    END
    ELSE
    IF
      (EXISTS (SELECT TOP 1
          p.Code
        FROM dbo.InsurancePolicy i
        INNER JOIN dbo.InsurancePolicyStatus p
          ON p.InsurancePolicyStatusId = i.PaymentStatusId
        WHERE i.InsurancePolicyId = @InsurancePolicyId
        AND p.Code = 'C02')
      OR EXISTS (SELECT TOP 1
          p.Code
        FROM dbo.InsuranceMonthlyPayment i
        INNER JOIN dbo.InsurancePolicyStatus p
          ON p.InsurancePolicyStatusId = i.PaymentStatusId
        WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId
        AND p.Code = 'C02')
      OR EXISTS (SELECT TOP 1
          p.Code
        FROM dbo.InsuranceRegistration i
        INNER JOIN dbo.InsurancePolicyStatus p
          ON p.InsurancePolicyStatusId = i.PaymentStatusId
        WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId
        AND p.Code = 'C02')
      )
    BEGIN

      SELECT
        -2

    END
    ELSE
    BEGIN

      DELETE dbo.InsuranceAchPayment
      WHERE InsuranceAchPaymentId = @InsuranceAchPaymentId

      -- Insurance policy
      IF (@InsurancePolicyId IS NOT NULL)
      BEGIN

        UPDATE dbo.InsurancePolicy
        SET ValidatedUSD = [dbo].[fn_CalculateInsuranceAchUsd](@InsurancePolicyId, NULL, NULL)
           ,LastUpdatedOn = @Date
           ,LastUpdatedBy = @UserId
        WHERE InsurancePolicyId = @InsurancePolicyId

        SET @achCount = (SELECT
            COUNT(*)
          FROM dbo.InsuranceAchPayment
          WHERE InsurancePolicyId = @InsurancePolicyId)

        IF (@achCount = 0)
        BEGIN

          UPDATE dbo.InsurancePolicy
          SET InsurancePaymentTypeId = NULL
          WHERE InsurancePolicyId = @InsurancePolicyId


        END

        SELECT
          @InsurancePolicyId

      END
      -- Insurance monthly
      ELSE
      IF (@InsuranceMonthlyPaymentId IS NOT NULL)
      BEGIN

        UPDATE dbo.InsuranceMonthlyPayment
        SET ValidatedUSD = [dbo].[fn_CalculateInsuranceAchUsd](NULL, @InsuranceMonthlyPaymentId, NULL)
           ,LastUpdatedOn = @Date
           ,LastUpdatedBy = @UserId
        WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

        SET @achCount = (SELECT
            COUNT(*)
          FROM dbo.InsuranceAchPayment
          WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

        IF (@achCount = 0)
        BEGIN

          UPDATE dbo.InsuranceMonthlyPayment
          SET InsurancePaymentTypeId = NULL
          WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId


        END

        SELECT
          @InsuranceMonthlyPaymentId


      END
      -- Insurance registration
      ELSE
      IF (@InsuranceRegistrationId IS NOT NULL)
      BEGIN

        UPDATE dbo.InsuranceRegistration
        SET ValidatedUSD = [dbo].[fn_CalculateInsuranceAchUsd](NULL, NULL, @InsuranceRegistrationId)
           ,LastUpdatedOn = @Date
           ,LastUpdatedBy = @UserId
        WHERE InsuranceRegistrationId = @InsuranceRegistrationId

        SET @achCount = (SELECT
            COUNT(*)
          FROM dbo.InsuranceAchPayment
          WHERE InsuranceRegistrationId = @InsuranceRegistrationId)

        IF (@achCount = 0)
        BEGIN

          UPDATE dbo.InsuranceRegistration
          SET InsurancePaymentTypeId = NULL
          WHERE InsuranceRegistrationId = @InsuranceRegistrationId


        END

        SELECT
          @InsuranceRegistrationId

      END

    END

  END



END
GO