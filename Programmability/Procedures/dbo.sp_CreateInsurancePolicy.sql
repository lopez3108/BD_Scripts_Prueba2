SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-04 DJ/6085: Add cashier commission
-- 2024-08-27 DJ/6016: Creates an insurance policy

-- =============================================
-- Author:      JF
-- Create date: 7/10/2024 4:39 p. m.
-- Database:    developing
-- Description: task : Validar teléfono cliente
-- =============================================

--26-11-2024 JT/6203 : Add news fields @CardFee DECIMAL(18, 2) = NULL, @PaymentType VARCHAR(50) = NULL,
-- 2024-11-25 JF/6232: Add nuevo campo INSURANCES NEW POLICY Y MONTHLY PAYMENT
-- 2024-12-02 DJ/6213: Insurance - lógica incorrecta al editar o eliminar un movimiento durante el día de su creación
-- 2024-12-08 JF/6243: Insurance - Add nuevo campo insurance
-- 2024-12-27 DJ/6266: Aplicar comisión provider a los insurance - NEW POLICY
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B
-- 2025-01-28 DJ/6316: INSURANCE - NEW POLICY comportamiento errado y dificil de comprender con el adjustment
-- 2025-02-12 DJ/6345: Pagar automáticamente movimiento hechos con card customer
-- 2025-02-19 JF/6351: Ajuste Configuración de Comisiones para Providers tipo INSURANCE - NEW POLICY
-- 2025-02-27 DJ/6365: Insurance quote
-- 2025-03-12 DJ/6391: Validación Automática de Transacciones con Balance en 0.00
-- 2025-04-22 DJ/6466: Seleccionar razón de insunrace completada
-- 2025-04-28 CB/6481: Agregar campos VIN a los Insurance policy

CREATE     PROCEDURE [dbo].[sp_CreateInsurancePolicy] @InsurancePolicyId INT = NULL,
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
@CashierCommission DECIMAL(18, 2) = NULL,
@TelIsCheck BIT = NULL,
@CreatedByMonthlyPayment BIT = 0,
@CardFee DECIMAL(18, 2) = NULL,
@PaymentType VARCHAR(50) = NULL,
@TransactionId VARCHAR(36) = NULL,
@MonthlyPaymentUsd DECIMAL(18, 2),
@FeeService DECIMAL(18, 2),
@FromMonthlyPayment BIT = 0,
@DOB DATETIME,
@InsuranceQuoteId INT = NULL,
@Result INT OUTPUT
AS

BEGIN

  DECLARE @paymentStatus INT
         ,@commissionStatus INT
         ,@currentPaymentStatusCode VARCHAR(5)
         ,@TransactionIdExist INT
         ,@paymentTypeCode VARCHAR(4)
         ,@adjustmentCard DECIMAL(18, 2)
         ,@paymentStatusId INT
		 ,@updateCompletedResult INT

		 DECLARE @InsuranceQuoteCompleteReasonId INT

	  SET @InsuranceQuoteCompleteReasonId = (SELECT TOP 1 InsuranceQuoteCompleteReasonId FROM
	  InsuranceQuoteCompleteReason WHERE Code = 'C01') -- SOLD

  SET @paymentTypeCode = (SELECT TOP 1
      PaymentType
    FROM dbo.InsurancePolicy i
    WHERE i.InsurancePolicyId = @Result)

  IF (@InsurancePolicyId IS NOT NULL)
  BEGIN

    SET @currentPaymentStatusCode = (SELECT TOP 1
        Code
      FROM dbo.InsurancePolicyStatus i
      WHERE i.InsurancePolicyStatusId = (SELECT TOP 1
          p.PaymentStatusId
        FROM dbo.InsurancePolicy p
        WHERE p.InsurancePolicyId = @InsurancePolicyId))


  END


  SET @TransactionIdExist = (SELECT
      COUNT(1)
    FROM InsuranceMonthlyPayment i
    WHERE i.TransactionId = @TransactionId);

  IF @TransactionIdExist > 0
  BEGIN

    SET @Result = -4
    SELECT
      @Result
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


    DECLARE @commissionUSD DECIMAL(18, 2)
           ,@currentProvider INT
           ,@currentPolicyType INT
           ,@currentCommissionType INT
           ,@currenCommission DECIMAL(18, 2)
           ,@insuranceCommissionTypeId INT

    IF (@InsurancePolicyId IS NULL)
    BEGIN

      IF (CAST(@ExpirationDate AS DATE) <= CAST(@CreationDate AS DATE))
      BEGIN

        SET @Result = -1

        SELECT
          @Result

      END
      ELSE
      BEGIN


        IF (@FromMonthlyPayment = CAST(0 AS BIT))
        BEGIN

          SET @insuranceCommissionTypeId = (SELECT TOP 1
              InsuranceCommissionTypeId
            FROM InsuranceCommissionType
            WHERE Code = 'C01')

          SET @commissionUSD = COALESCE(
    (SELECT TOP 1 icptm.USD
     FROM InsuranceCommissionPolicyTypeMovement icptm
     WHERE icptm.ProviderId = @ProviderId
       AND icptm.PolicyTypeId = @PolicyTypeId
       AND icptm.InsuranceCommissionTypeId = @insuranceCommissionTypeId), 
    0
);


        --	  SET @commissionUSD = (SELECT TOP 1 ISNULL(c.USD,0) 
        --	  FROM dbo.InsuranceCommissionType i LEFT JOIN dbo.InsuranceCommissionTypeXProvider c
        --	  ON c.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId AND c.ProviderId = @ProviderId
        --	  WHERE i.Code = 'C01')

        END
        ELSE
        BEGIN

          SET @commissionUSD = 0

        END

        INSERT INTO [dbo].[InsurancePolicy] ([ProviderId]
        , [InsuranceCompaniesId]
        , [ClientName]
        , [ClientTelephone]
        , [ExpirationDate]
        , [PolicyNumber]
        , [USD]
        , [CreatedBy]
        , [CreationDate]
        , [LastUpdatedOn]
        , [LastUpdatedBy]
        , [CreatedInAgencyId]
        , [PolicyTypeId]
        , [Cash]
        , PaymentStatusId
        , CommissionStatusId,
        CashierCommission,
        TelIsCheck,
        CreatedByMonthlyPayment,
        CardFee,
        PaymentType,
        TransactionId,
        MonthlyPaymentUsd,
        FeeService,
        CommissionUsd,
        DOB,
		InsuranceQuoteId)
          VALUES (@ProviderId, @InsuranceCompaniesId, @ClientName, @ClientTelephone, @ExpirationDate, @PolicyNumber, @USD, @CreatedBy, @CreationDate, @LastUpdatedOn, @LastUpdatedBy, @CreatedInAgencyId, @PolicyTypeId, @Cash, @paymentStatus, @commissionStatus, @CashierCommission, @TelIsCheck, @CreatedByMonthlyPayment, @CardFee, @PaymentType, @TransactionId, @MonthlyPaymentUsd, @FeeService, @commissionUSD, @DOB, @InsuranceQuoteId)

        SET @Result = @@IDENTITY


		-- 6365

		IF(@InsuranceQuoteId IS NOT NULL)
		BEGIN

		IF((SELECT TOP 1 q.InsuranceQuoteStatusCode FROM dbo.InsuranceQuote q WHERE q.InsuranceQuoteId = @InsuranceQuoteId) = 'C02')--COMPLETED
		BEGIN

		SELECT -8 -- CANNOT USE QUOTE BECAUSE ITS ALREADY COMPLETED

		END
		ELSE
		BEGIN
		EXEC dbo.sp_UpdateInsuranceQuoteComplete @InsuranceQuoteId, @CreatedBy, @LastUpdatedOn, @CreatedInAgencyId, 'C02',@InsuranceQuoteCompleteReasonId, @updateCompletedResult -- COMPLETED
		END

		END


        SET @paymentTypeCode = (SELECT TOP 1
            PaymentType
          FROM dbo.InsurancePolicy i
          WHERE i.InsurancePolicyId = @Result)


        -- 6345

        IF (@CreatedByMonthlyPayment = CAST(0 AS BIT)
          OR @CreatedByMonthlyPayment IS NULL)
        BEGIN

          IF (@paymentTypeCode = 'C02')
          BEGIN

            SET @adjustmentCard = [dbo].[fn_CalculateInsuranceAdjustment](@Result, NULL, NULL)

            IF (@adjustmentCard = 0)
            BEGIN

              SET @paymentStatusId = (SELECT TOP 1
                  InsurancePolicyStatusId
                FROM dbo.InsurancePolicyStatus i
                WHERE i.Code = 'C02') --PAID

              UPDATE dbo.InsurancePolicy
              SET PaymentStatusId = @paymentStatusId
                 ,ValidatedBy = @CreatedBy
                 ,ValidatedOn = @CreationDate
                 ,ValidatedAgencyId = @CreatedInAgencyId
              WHERE InsurancePolicyId = @Result

            END

          END

        END

        SELECT
          @Result

      END

    END
    ELSE
    BEGIN

      SELECT
        @currentProvider = i.ProviderId
       ,@currentPolicyType = i.PolicyTypeId
       ,@currenCommission = i.CommissionUsd
      FROM dbo.InsurancePolicy i
      WHERE i.InsurancePolicyId = @InsurancePolicyId

      IF (@currentProvider = @ProviderId
        AND @currentPolicyType = @PolicyTypeId)
      BEGIN

        SET @commissionUSD = @currenCommission

      END
      ELSE
      BEGIN
        SET @insuranceCommissionTypeId = (SELECT TOP 1
            InsuranceCommissionTypeId
          FROM InsuranceCommissionType
          WHERE Code = 'C01')

               SET @commissionUSD = COALESCE(
    (SELECT TOP 1 icptm.USD
     FROM InsuranceCommissionPolicyTypeMovement icptm
     WHERE icptm.ProviderId = @ProviderId
       AND icptm.PolicyTypeId = @PolicyTypeId
       AND icptm.InsuranceCommissionTypeId = @insuranceCommissionTypeId), 
    0
);

      --        SET @commissionUSD = (SELECT
      --            ISNULL(i.USD, 0) AS CommissionUsd
      --          FROM dbo.InsuranceCommissionType c
      --          LEFT JOIN dbo.InsuranceCommissionTypeXProvider i
      --            ON c.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
      --            AND i.ProviderId = @ProviderId
      --          WHERE c.Code = 'C01')

      END

	  DECLARE @initialQuoteId INT
	  SET @initialQuoteId = (SELECT TOP 1 i.InsuranceQuoteId FROM dbo.InsurancePolicy i WHERE i.InsurancePolicyId = @InsurancePolicyId)

      UPDATE [dbo].[InsurancePolicy]
      SET [ProviderId] = @ProviderId
         ,[InsuranceCompaniesId] = @InsuranceCompaniesId
         ,[ClientName] = @ClientName
         ,[ClientTelephone] = @ClientTelephone
         ,[ExpirationDate] = @ExpirationDate
         ,[PolicyNumber] = @PolicyNumber
         ,[PolicyTypeId] = @PolicyTypeId
         ,[USD] = @USD
         ,[LastUpdatedOn] = @LastUpdatedOn
         ,[LastUpdatedBy] = @LastUpdatedBy
         ,[Cash] = @Cash
--         ,[PaymentStatusId] = @paymentStatus
         ,[CommissionStatusId] = @commissionStatus
         ,[TelIsCheck] = @TelIsCheck
         ,CardFee = @CardFee
         ,PaymentType = @PaymentType
         ,TransactionId = @TransactionId
         ,MonthlyPaymentUsd = @MonthlyPaymentUsd
         ,FeeService = @FeeService
         ,[CommissionUsd] = @commissionUSD
         ,DOB = @DOB
--         ,ValidatedBy = NULL
--         ,ValidatedAgencyId = NULL
--         ,ValidatedOn = NULL
		 ,[InsuranceQuoteId] = @InsuranceQuoteId
      WHERE InsurancePolicyId = @InsurancePolicyId

	   SET @Result = @InsurancePolicyId

	  -- 6365

	  IF(@initialQuoteId IS NOT NULL AND @initialQuoteId <> @InsuranceQuoteId)
	  BEGIN

	  EXEC dbo.sp_UpdateInsuranceQuoteComplete @initialQuoteId, NULL, NULL, NULL, 'C01', @InsuranceQuoteCompleteReasonId, @updateCompletedResult -- PENDING


	  END

		IF(@InsuranceQuoteId IS NOT NULL)
		BEGIN

		EXEC dbo.sp_UpdateInsuranceQuoteComplete @InsuranceQuoteId, @CreatedBy, @CreationDate, @CreatedInAgencyId, 'C02', @InsuranceQuoteCompleteReasonId, @updateCompletedResult -- COMPLETED


		END

      SET @paymentTypeCode = (SELECT TOP 1
          PaymentType
        FROM dbo.InsurancePolicy i
        WHERE i.InsurancePolicyId = @Result)


      -- 6345

      IF (@CreatedByMonthlyPayment = CAST(0 AS BIT)
        OR @CreatedByMonthlyPayment IS NULL)
      BEGIN
     

          SET @adjustmentCard = [dbo].[fn_CalculateInsuranceAdjustment](@Result, NULL, NULL)

          IF (@adjustmentCard = 0)
          BEGIN

            SET @paymentStatusId = (SELECT TOP 1
                InsurancePolicyStatusId
              FROM dbo.InsurancePolicyStatus i
              WHERE i.Code = 'C02') --PAID

            UPDATE dbo.InsurancePolicy
            SET PaymentStatusId = @paymentStatusId
               ,ValidatedBy = @LastUpdatedBy
               ,ValidatedOn = @LastUpdatedOn
               ,ValidatedAgencyId = @CreatedInAgencyId
            WHERE InsurancePolicyId = @Result

          END


      END

      SELECT
        @Result

    END
  END

END
GO