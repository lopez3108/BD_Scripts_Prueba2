SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-01-11 DJ/6253: Nuevo reporte insurances commissions
-- 2025-01-15 JF/6287: Ajustes generales INSURANCE
-- 2025-02-06 DJ/6330: Contrapartida reporte INSURANCE COMMISSIONS
-- 2025-02-11 JF/6342: eporte Insurance Commisions - Campo Type muestra formato de fecha errada
-- 2025-02-19 DJ/6354: Visualización del Valor Pagado en el Reporte de Comisiones INSURANCE
-- 2025-02-06 JT/6382: Reporte - Valores de la columna BALANCE no son correctos en el tab INSURANCE COMMISIONS

CREATE FUNCTION [dbo].[FN_GetInsuranceCommissions] (@AgencyId INT,
@ProviderId INT,
@FromDate DATETIME,
@ToDate DATETIME,
@InsuranceTypeIds VARCHAR(100) = NULL)
RETURNS @Result TABLE (
 [Index] INT
 ,[Group] INT
 ,[Date] DATETIME
 ,[Type] VARCHAR(40)
 ,[Description] VARCHAR(80)
 ,FeeService DECIMAL(18, 2)
 ,CommissionProvider DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2) NULL
 ,BalanceDetail DECIMAL(18, 2)
 ,InsuranceId INT
 ,[DateRaw] DATETIME
 ,CounterPartIndex INT
)
AS

BEGIN

  DECLARE @newPolicySelected BIT = 0;
  DECLARE @monthlyPaymentSelected BIT = 0;
  DECLARE @sosSelected BIT = 0;
  DECLARE @endorsementSelected BIT = 0;  -- Default: FALSE
  DECLARE @policyRenewalSelected BIT = 0;  -- Default: FALSE

  IF CHARINDEX('1', @InsuranceTypeIds) > 0
    SET @newPolicySelected = 1;
  IF CHARINDEX('2', @InsuranceTypeIds) > 0
    SET @monthlyPaymentSelected = 1;
  IF CHARINDEX('3', @InsuranceTypeIds) > 0
    SET @sosSelected = 1;
  IF CHARINDEX('4', @InsuranceTypeIds) > 0
    SET @endorsementSelected = 1;  -- TRUE
  IF CHARINDEX('5', @InsuranceTypeIds) > 0
    SET @policyRenewalSelected = 1;  -- TRUE


  INSERT INTO @Result
    SELECT
      *
   
      FROM (
        -- New policy
        SELECT
          1 [Index]
         ,4 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'NEW POLICY' [Type]
         ,'CLOSING DAILY' [Description]
         ,i.FeeService [FeeService]
         ,i.CommissionUsd [CommissionProvider]
         ,0 [Credit]
         ,ISNULL(i.FeeService, 0) + ISNULL(i.CommissionUsd, 0) [Balance]
         ,InsurancePolicyId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,1 AS CounterPartIndex
        FROM [dbo].[InsurancePolicy] i
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (i.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.CreatedByMonthlyPayment = CAST(0 AS BIT)
        AND @newPolicySelected = CAST(1 AS BIT)

        UNION ALL

        -- New policy PAID
        SELECT
          1 [Index]
         ,5 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING COMMISSION' [Description]
         ,0 [FeeService]
         ,0 [CommissionProvider]
         ,ISNULL(i.FeeService, 0) + ISNULL(i.CommissionUsd, 0) [Credit]
         ,(ISNULL(i.FeeService, 0) + ISNULL(i.CommissionUsd, 0)) * -1 [Balance]
         ,InsurancePolicyId [InsuranceId]
         ,i.ValidatedOn CreationDateRaw
         ,2 AS CounterPartIndex
        FROM [dbo].[InsurancePolicy] i
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (i.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.CreatedByMonthlyPayment = CAST(0 AS BIT)
        AND @newPolicySelected = CAST(1 AS BIT)
        AND i.ValidatedOn IS NOT NULL



        -- Monthly payments

        UNION ALL

        -- Monthly payments
        SELECT
          2 [Index]
         ,4 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,t.Description [Type]
         ,'CLOSING DAILY' [Description]
         ,i.MonthlyPaymentServiceFee [FeeService]
         ,i.CommissionUsd [CommissionProvider]
         ,0 [Credit]
         ,ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0) [Balance]
         ,InsuranceMonthlyPaymentId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,1 AS CounterPartIndex
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsuranceCommissionType t
          ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND (@monthlyPaymentSelected = CAST(1 AS BIT)
        AND t.Code = 'C04')

        UNION ALL

        -- Monthly payments PAID
        SELECT
          2 [Index]
         ,5 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING COMMISSION' [Description]
         ,0 [FeeService]
         ,0 [CommissionProvider]
         ,ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0) [Credit]
         ,(ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0)) * -1 [Balance]
         ,InsuranceMonthlyPaymentId [InsuranceId]
         ,i.ValidatedOn CreationDateRaw
         ,2 AS CounterPartIndex
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsuranceCommissionType t
          ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND (@monthlyPaymentSelected = CAST(1 AS BIT)
        AND t.Code = 'C04')
        AND i.ValidatedOn IS NOT NULL

        -- endorsement

        UNION ALL


        SELECT
          3 [Index]
         ,4 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,t.Description [Type]
         ,'CLOSING DAILY' [Description]
         ,i.MonthlyPaymentServiceFee [FeeService]
         ,i.CommissionUsd [CommissionProvider]
         ,0 [Credit]
         ,ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0) [Balance]
         ,InsuranceMonthlyPaymentId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,1 AS CounterPartIndex
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsuranceCommissionType t
          ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND (@endorsementSelected = CAST(1 AS BIT)
        AND t.Code = 'C03')

        UNION ALL

        -- endorsement PAID

        SELECT
          3 [Index]
         ,5 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING COMMISSION' [Description]
         ,0 [FeeService]
         ,0 [CommissionProvider]
         ,ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0) [Credit]
         ,(ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0)) * -1 [Balance]
         ,InsuranceMonthlyPaymentId [InsuranceId]
         ,i.ValidatedOn CreationDateRaw
         ,2 AS CounterPartIndex
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsuranceCommissionType t
          ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND (@endorsementSelected = CAST(1 AS BIT)
        AND t.Code = 'C03')
        AND i.ValidatedOn IS NOT NULL

        -- policyRenewal

        UNION ALL


        SELECT
          4 [Index]
         ,4 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,t.Description [Type]
         ,'CLOSING DAILY' [Description]
         ,i.MonthlyPaymentServiceFee [FeeService]
         ,i.CommissionUsd [CommissionProvider]
         ,0 [Credit]
         ,ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0) [Balance]
         ,InsuranceMonthlyPaymentId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,1 AS CounterPartIndex
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsuranceCommissionType t
          ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND (@policyRenewalSelected = CAST(1 AS BIT)
        AND t.Code = 'C02')

        UNION ALL

        -- policyRenewal PAID

        SELECT
          4 [Index]
         ,5 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING COMMISSION' [Description]
         ,0 [FeeService]
         ,0 [CommissionProvider]
         ,ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0) [Credit]
         ,(ISNULL(i.MonthlyPaymentServiceFee, 0) + ISNULL(i.CommissionUsd, 0)) * -1 [Balance]
         ,InsuranceMonthlyPaymentId [InsuranceId]
         ,i.ValidatedOn CreationDateRaw
         ,2 AS CounterPartIndex
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsuranceCommissionType t
          ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND (@policyRenewalSelected = CAST(1 AS BIT)
        AND t.Code = 'C02')
        AND i.ValidatedOn IS NOT NULL

        -- Insurance registration

        UNION ALL

        --Insurance registration
        SELECT
          5 [Index]
         ,4 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'REGISTRATION RELEASE (S.O.S)' [Type]
         ,'CLOSING DAILY' [Description]
         ,i.RegistrationReleaseSOSFee [FeeService]
         ,0 [CommissionProvider]
         ,0 [Credit]
         ,ISNULL(i.RegistrationReleaseSOSFee, 0) [Balance]
         ,InsuranceRegistrationId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,1 AS CounterPartIndex
        FROM [dbo].[InsuranceRegistration] i
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ProviderId = @ProviderId
        AND @sosSelected = CAST(1 AS BIT)

        UNION ALL

        --Insurance registration PAID
        SELECT
          5 [Index]
         ,5 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING COMMISSION' [Description]
         ,0 [FeeService]
         ,0 [CommissionProvider]
         ,ISNULL(i.RegistrationReleaseSOSFee, 0) [Credit]
         ,(ISNULL(i.RegistrationReleaseSOSFee, 0)) * -1 [Balance]
         ,InsuranceRegistrationId [InsuranceId]
         ,i.ValidatedOn CreationDateRaw
         ,2 AS CounterPartIndex
        FROM [dbo].[InsuranceRegistration] i
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ProviderId = @ProviderId
        AND @sosSelected = CAST(1 AS BIT)
        AND i.ValidatedOn IS NOT NULL

        UNION ALL


        --Insurance provider commission DEBIT
        SELECT
          6 [Index]
         ,4 [Group]
         ,DATEADD(MONTH, 1, CAST((CAST(i.year AS VARCHAR(4)) + '-' + CAST(i.month AS VARCHAR(2)) + '-01') AS Date)) AS [Date]
         ,'COMMISSION' [Type]
         ,'COMM. ' + UPPER(DateName( month , DateAdd( month , i.month , 0 ) - 1 )) + ' - ' + CAST(i.year AS VARCHAR(4)) [Description]
         ,0 [FeeService]
         ,i.USD [CommissionProvider]
         ,0 [Credit]
         ,i.USD [Balance]
         ,ProviderCommissionPaymentId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,1 AS CounterPartIndex
        FROM [dbo].ProviderCommissionPayments i
        WHERE (i.AgencyId = @AgencyId)
        AND (CAST(DATEADD(MONTH, 1, CAST((CAST(i.year AS VARCHAR(4)) + '-' + CAST(i.month AS VARCHAR(2)) + '-01') AS Date)) as DATE) >= CAST(@FromDate AS Date)
        AND CAST(DATEADD(MONTH, 1, CAST((CAST(i.year AS VARCHAR(4)) + '-' + CAST(i.month AS VARCHAR(2)) + '-01') AS Date)) as DATE) <= CAST(@ToDate AS Date))
        AND i.ProviderId = @ProviderId

        UNION ALL

        --Insurance provider commission CREDIT
        SELECT
          6 [Index]
         ,5 [Group]
         ,DATEADD(MONTH, 1, CAST((CAST(i.Year AS VARCHAR(4)) + '-' + CAST(i.Month AS VARCHAR(2)) + '-01') AS Date)) AS [Date]
         ,'COMMISSION' [Type]
         ,'COMM. ' + UPPER(DateName( month , DateAdd( month , i.month , 0 ) - 1 )) + ' - ' + CAST(i.Year AS VARCHAR(4)) [Description]
         ,0 [FeeService]
         ,0 [CommissionProvider]
         ,i.Usd [Credit]
         ,(i.Usd * -1) [Balance]
         ,ProviderCommissionPaymentId [InsuranceId]
         ,i.CreationDate CreationDateRaw
         ,2 AS CounterPartIndex
        FROM [dbo].ProviderCommissionPayments i
        WHERE (i.AgencyId = @AgencyId)
         AND (CAST(DATEADD(MONTH, 1, CAST((CAST(i.year AS VARCHAR(4)) + '-' + CAST(i.month AS VARCHAR(2)) + '-01') AS Date)) as DATE) >= CAST(@FromDate AS Date)
        AND CAST(DATEADD(MONTH, 1, CAST((CAST(i.year AS VARCHAR(4)) + '-' + CAST(i.month AS VARCHAR(2)) + '-01') AS Date)) as DATE) <= CAST(@ToDate AS Date))
        AND i.ProviderId = @ProviderId) AS Query
    



  RETURN;
END;
GO