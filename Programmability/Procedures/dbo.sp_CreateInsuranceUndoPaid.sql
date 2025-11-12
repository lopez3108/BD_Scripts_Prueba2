SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-24 DJ/6020: Undo insurance payment operation
-- 2025-04-04 DJ/6422: Ajustes Deshacer (Undo) insurance
-- 2025-05-05 DJ/6489: Permitir Undo a cualquier administrador con registro de auditoría

CREATE PROCEDURE [dbo].[sp_CreateInsuranceUndoPaid] @InsurancePolicyId INT = NULL,
@InsuranceMonthlyPaymentId INT = NULL,
@InsuranceRegistrationId INT = NULL,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@UserId INT,
@Date DATETIME
AS
BEGIN

  DECLARE @policyStatusPending INT
         ,@createdBy INT = NULL
         ,@creationDate DATETIME
         ,@insuranceStatus VARCHAR(4)
         ,@currentPaidStatus INT
         ,@insurancePaymentTypeId INT

  SET @policyStatusPending = (SELECT TOP 1
      InsurancePolicyStatusId
    FROM InsurancePolicyStatus i
    WHERE i.Code = 'C01')

  SET @insurancePaymentTypeId = (SELECT TOP 1
      InsurancePaymentTypeId
    FROM InsurancePaymentType i
    WHERE i.Code = 'C01')


  IF (@InsurancePolicyId IS NOT NULL)
  BEGIN

   
        UPDATE [dbo].[InsurancePolicy]
        SET [ValidatedOn] = NULL
           ,[ValidatedBy] = NULL
           ,[ValidatedAgencyId] = NULL
           ,[ValidatedUSD] =
            CASE
              WHEN InsurancePaymentTypeId = @insurancePaymentTypeId THEN NULL
              ELSE ValidatedUSD
            END
           ,[InsurancePaymentTypeId] =
            CASE
              WHEN InsurancePaymentTypeId = @insurancePaymentTypeId THEN NULL
              ELSE InsurancePaymentTypeId
            END
           ,[PaymentStatusId] = @policyStatusPending
           ,[LastUpdatedBy] = @LastUpdatedBy
           ,[LastUpdatedOn] = @LastUpdatedOn
        WHERE InsurancePolicyId = @InsurancePolicyId

        SELECT
          @InsurancePolicyId

  END
  ELSE
  IF (@InsuranceMonthlyPaymentId IS NOT NULL)
  BEGIN

   

        UPDATE [dbo].[InsuranceMonthlyPayment]
        SET [ValidatedOn] = NULL
           ,[ValidatedBy] = NULL
           ,[ValidatedAgencyId] = NULL
             ,[ValidatedUSD] =
            CASE
              WHEN InsurancePaymentTypeId = @insurancePaymentTypeId THEN NULL
              ELSE ValidatedUSD
            END
           ,[InsurancePaymentTypeId] =
            CASE
              WHEN InsurancePaymentTypeId = @insurancePaymentTypeId THEN NULL
              ELSE InsurancePaymentTypeId
            END
           ,[PaymentStatusId] = @policyStatusPending
           ,[LastUpdatedBy] = @LastUpdatedBy
           ,[LastUpdatedOn] = @LastUpdatedOn
        WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

        SELECT
          @InsuranceMonthlyPaymentId
  END
  ELSE
  IF (@InsuranceRegistrationId IS NOT NULL)
  BEGIN

    

        UPDATE [dbo].[InsuranceRegistration]
        SET [ValidatedOn] = NULL
           ,[ValidatedBy] = NULL
           ,[ValidatedAgencyId] = NULL
             ,[ValidatedUSD] =
            CASE
              WHEN InsurancePaymentTypeId = @insurancePaymentTypeId THEN NULL
              ELSE ValidatedUSD
            END
           ,[InsurancePaymentTypeId] =
            CASE
              WHEN InsurancePaymentTypeId = @insurancePaymentTypeId THEN NULL
              ELSE InsurancePaymentTypeId
            END
           ,[PaymentStatusId] = @policyStatusPending
           ,[LastUpdatedBy] = @LastUpdatedBy
           ,[LastUpdatedOn] = @LastUpdatedOn
        WHERE InsuranceRegistrationId = @InsuranceRegistrationId

        SELECT
          @InsuranceRegistrationId

     
  END

END



GO