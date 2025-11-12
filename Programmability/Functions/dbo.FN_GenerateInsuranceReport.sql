SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-01 CB/6023: Insurance report
-- 2024-10-28 JT/6115: Gets ONLY the daily insurance adjusment details <> 0
-- 2024-10-28 JF/6134: No se están reflejando los pagos de card customer en reporte general
-- 2024-10-03 CB/6023: Insurance report general
-- 2024-11-17 JF/6191: Ajustes reporte insurance
-- 2024-11-17 JF/6311: Report Insurance - Los pagos no están apareciendo debajo de los registros de ventas
-- 2025-01-05 DJ/6329: Ajuste pagos ACH
-- 2025-02-12 JT/6329: Only show TypeId =  { id: 1, name: 'DEBIT' },{ id: 2, name: 'CREDIT' },
-- 2025-04-20 DJ/6425: Aplicar nueva lógica para pago COMMISSION USD(PROVIDER)

CREATE FUNCTION [dbo].[FN_GenerateInsuranceReport] (@AgencyId INT,
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
 ,[Transactions] INT
 ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2) NULL
 ,BalanceDetail DECIMAL(18, 2)
)
AS

BEGIN


  -- Declarar las variables v1, v2 y v3
  DECLARE @newPolicySelected BIT = 0;  -- Default: FALSE
  DECLARE @monthlyPaymentSelected BIT = 0;  -- Default: FALSE
  DECLARE @sosSelected BIT = 0;  -- Default: FALSE
  DECLARE @endorsementSelected BIT = 0;  -- Default: FALSE
  DECLARE @policyRenewalSelected BIT = 0;  -- Default: FALSE

  -- Asignar valores a v1, v2 y v3 en función de los valores de @InsuranceIds
  IF CHARINDEX('1', @InsuranceTypeIds) > 0
    SET @newPolicySelected = 1;  -- TRUE
  IF CHARINDEX('2', @InsuranceTypeIds) > 0
    SET @monthlyPaymentSelected = 1;  -- TRUE
  IF CHARINDEX('3', @InsuranceTypeIds) > 0
    SET @sosSelected = 1;  -- TRUE
  IF CHARINDEX('4', @InsuranceTypeIds) > 0
    SET @endorsementSelected = 1;  -- TRUE
  IF CHARINDEX('5', @InsuranceTypeIds) > 0
    SET @policyRenewalSelected = 1;  -- TRUE

  DECLARE @insurancePaymentTypeCodeCash VARCHAR(5)
         ,@insurancePaymentTypeCodeAch VARCHAR(5)
  SET @insurancePaymentTypeCodeCash = (SELECT TOP 1
      i.Code
    FROM dbo.InsurancePaymentType i
    WHERE Code = 'C01')
  SET @insurancePaymentTypeCodeAch = (SELECT TOP 1
      i.Code
    FROM dbo.InsurancePaymentType i
    WHERE Code = 'C04')

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
       ,COUNT(*) [Transactions]
       ,NULL [Debit]
       ,SUM(ISNULL(i.USD, 0)) [Credit]
       ,SUM(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsurancePolicy] i
      WHERE (i.CreatedInAgencyId = @AgencyId) 
      AND (i.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND i.CreatedByMonthlyPayment = CAST(0 AS BIT)
      AND @newPolicySelected = CAST(1 AS BIT)
      Group BY CAST(i.CreationDate AS Date)

	  UNION ALL

	  -- New policy provider commission
      SELECT
        1 [Index]
       ,5 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'COMMISSION PROVIDER' [Type]
       ,'CLOSING DAILY – COMMISSION PROVIDER' [Description]
       ,COUNT(*) [Transactions]
       ,SUM(i.CommissionUsd) [Debit]
       ,NULL [Credit]
       ,SUM(ISNULL(i.CommissionUsd * -1, 0)) [Balance]
      FROM [dbo].[InsurancePolicy] i
      WHERE (i.CreatedInAgencyId = @AgencyId) 
      AND (i.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND i.CreatedByMonthlyPayment = CAST(0 AS BIT)
      AND @newPolicySelected = CAST(1 AS BIT)
	  AND i.CommissionUsd > 0
      Group BY CAST(i.CreationDate AS Date)

      UNION ALL
      -- New policy cash payments
      SELECT
        1 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - CASH PAYMENT' [Description]
       ,1 [Transactions]
       ,i.ValidatedUSD [Debit]
       ,NULL [Credit]
       ,(i.ValidatedUSD * -1) [Balance]
      FROM [dbo].[InsurancePolicy] i
      INNER JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (i.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeCash
      AND @newPolicySelected = CAST(1 AS BIT)

      UNION ALL
      -- New policy ach payments
      SELECT
        1 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(a.CreationDate, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - ACH PAYMENT' [Description]
       ,1 [Transactions]
       ,CASE
          WHEN a.TypeId = 1 THEN a.USD
          ELSE 0
        END [Debit]
       ,CASE
          WHEN a.TypeId = 1 THEN 0
          ELSE a.USD
        END [Credit]
       ,CASE
          WHEN a.TypeId = 1 THEN (a.USD * -1)
          ELSE a.USD
        END [Balance]
      FROM dbo.InsuranceAchPayment a
      INNER JOIN [dbo].[InsurancePolicy] i
        ON i.InsurancePolicyId = a.InsurancePolicyId
      LEFT JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (i.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeAch
      AND @newPolicySelected = CAST(1 AS BIT) AND (TypeId = 1 OR TypeId = 2)-- only for  { id: 1, name: 'DEBIT' },{ id: 2, name: 'CREDIT' },

      UNION ALL
      -- New policy Adjustment
      SELECT
        *
      FROM (SELECT
          1 [Index]
         ,6 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'ADJUSTMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING DAILY - ADJUSTMENT ' +
          CASE
            WHEN ipt.Code = @insurancePaymentTypeCodeCash THEN 'CASH'
            ELSE 'ACH'
          END [Description]
         ,1 [Transactions]
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) >= 0 THEN [dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL)
            ELSE NULL
          END Debit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) < 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL)) * -1
            ELSE NULL
          END Credit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) >= 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) * -1)
            ELSE (([dbo].[fn_CalculateInsuranceAdjustment](i.InsurancePolicyId, NULL, NULL) * -1))
          END [Balance]
        FROM [dbo].[InsurancePolicy] i
        INNER JOIN dbo.InsurancePaymentType ipt
          ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (i.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ValidatedBy IS NOT NULL
        AND @newPolicySelected = CAST(1 AS BIT)) qa1
      WHERE (qa1.Debit <> 0
      OR qa1.Credit <> 0)

      -- Monthly payments

      UNION ALL

      -- Monthly payments
      SELECT
        2 [Index]
       ,4 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
        --       ,'MONTHLY PAYMENT' [Type]
       ,ict.Description [Type]
       ,'CLOSING DAILY' [Description]
       ,COUNT(*) [Transactions]
       ,NULL [Debit]
       ,SUM(ISNULL(i.USD, 0)) [Credit]
       ,SUM(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (@monthlyPaymentSelected = CAST(1 AS BIT)
      AND ict.Code = 'C04')
      Group BY CAST(i.CreationDate AS Date)
              ,ict.Description


      UNION ALL

      -- endorsement
      SELECT
        4 [Index]
       ,4 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
        --       ,'MONTHLY PAYMENT1' [Type]
       ,ict.Description [Type]
       ,'CLOSING DAILY' [Description]
       ,COUNT(*) [Transactions]
       ,NULL [Debit]
       ,SUM(ISNULL(i.USD, 0)) [Credit]
       ,SUM(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (@endorsementSelected = CAST(1 AS BIT)
      AND ict.Code = 'C03')
      Group BY CAST(i.CreationDate AS Date)
              ,ict.Description

      UNION ALL


      -- policyRenewal
      SELECT
        5 [Index]
       ,4 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
        --       ,'MONTHLY PAYMENT1' [Type]
       ,ict.Description [Type]
       ,'CLOSING DAILY' [Description]
       ,COUNT(*) [Transactions]
       ,NULL [Debit]
       ,SUM(ISNULL(i.USD, 0)) [Credit]
       ,SUM(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (@policyRenewalSelected = CAST(1 AS BIT)
      AND ict.Code = 'C02')
      Group BY CAST(i.CreationDate AS Date)
              ,ict.Description

			 
			   UNION ALL

			  -- Monthly payments commission provider
      SELECT
        2 [Index]
       ,5 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
        ,'COMMISSION PROVIDER' [Type]
       ,'CLOSING DAILY – COMMISSION PROVIDER' [Description]
       ,COUNT(*) [Transactions]
       ,SUM(i.CommissionUsd) [Debit]
       ,NULL [Credit]
       ,SUM(ISNULL(i.CommissionUsd * -1, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (@monthlyPaymentSelected = CAST(1 AS BIT)
      AND ict.Code = 'C04')
	   AND i.CommissionUsd > 0
      Group BY CAST(i.CreationDate AS Date)
              ,ict.Description

      UNION ALL
      -- Monthly payment cash payments
      SELECT
        2 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - CASH PAYMENT' [Description]
       ,1 [Transactions]
       ,i.ValidatedUSD [Debit]
       ,NULL [Credit]
       ,(i.ValidatedUSD * -1) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeCash
      AND (@monthlyPaymentSelected = CAST(1 AS BIT)
      AND ict.Code = 'C04')

      UNION ALL
      -- Monthly payment ach payments
      SELECT
        2 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(a.CreationDate, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - ACH PAYMENT' [Description]
       ,1 [Transactions]
       ,CASE
          WHEN a.TypeId = 1 THEN a.USD
          ELSE 0
        END [Debit]
       ,CASE
          WHEN a.TypeId = 1 THEN 0
          ELSE a.USD
        END [Credit]
       ,CASE
          WHEN a.TypeId = 1 THEN (a.USD * -1)
          ELSE a.USD
        END [Balance]
      FROM dbo.InsuranceAchPayment a
      INNER JOIN [dbo].[InsuranceMonthlyPayment] i
        ON i.InsuranceMonthlyPaymentId = a.InsuranceMonthlyPaymentId
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      LEFT JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeAch
      AND (@monthlyPaymentSelected = CAST(1 AS BIT)
      AND ict.Code = 'C04')  AND (TypeId = 1 OR TypeId = 2)-- only for  { id: 1, name: 'DEBIT' },{ id: 2, name: 'CREDIT' },

      UNION ALL
      -- Monthly payment Adjustment
      SELECT
        *
      FROM (SELECT
          2 [Index]
         ,6 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'ADJUSTMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING DAILY - ADJUSTMENT ' +
          CASE
            WHEN ipt.Code = @insurancePaymentTypeCodeCash THEN 'CASH'
            ELSE 'ACH'
          END [Description]
         ,1 [Transactions]
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) >= 0 THEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL)
            ELSE NULL
          END Debit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) < 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL)) * -1
            ELSE NULL
          END Credit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) >= 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) * -1)
            ELSE (([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) * -1))
          END [Balance]
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsurancePaymentType ipt
          ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
        INNER JOIN InsuranceCommissionType ict
          ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ValidatedBy IS NOT NULL
        AND (@monthlyPaymentSelected = CAST(1 AS BIT)
        AND ict.Code = 'C04')) qa2
      WHERE (qa2.Debit <> 0
      OR qa2.Credit <> 0)

	  UNION ALL

	   -- Monthly payments endorsemente commission provider
      SELECT
        4 [Index]
       ,5 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
        ,'COMMISSION PROVIDER' [Type]
       ,'CLOSING DAILY – COMMISSION PROVIDER' [Description]
       ,COUNT(*) [Transactions]
       ,SUM(i.CommissionUsd) [Debit]
       ,NULL [Credit]
       ,SUM(ISNULL(i.CommissionUsd * -1, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (@endorsementSelected = CAST(1 AS BIT)
       AND ict.Code = 'C03')
	    AND i.CommissionUsd > 0
      Group BY CAST(i.CreationDate AS Date)
              ,ict.Description

      UNION ALL
      -- Monthly payment cash endorsement
      SELECT
        4 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - CASH PAYMENT' [Description]
       ,1 [Transactions]
       ,i.ValidatedUSD [Debit]
       ,NULL [Credit]
       ,(i.ValidatedUSD * -1) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeCash
      AND (@endorsementSelected = CAST(1 AS BIT)
      AND ict.Code = 'C03')

      UNION ALL
      -- Monthly payment ach endorsement
      SELECT
        4 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(a.CreationDate, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - ACH PAYMENT' [Description]
       ,1 [Transactions]
       ,CASE
          WHEN a.TypeId = 1 THEN a.USD
          ELSE 0
        END [Debit]
       ,CASE
          WHEN a.TypeId = 1 THEN 0
          ELSE a.USD
        END [Credit]
       ,CASE
          WHEN a.TypeId = 1 THEN (a.USD * -1)
          ELSE a.USD
        END [Balance]
      FROM dbo.InsuranceAchPayment a
      INNER JOIN [dbo].[InsuranceMonthlyPayment] i
        ON i.InsuranceMonthlyPaymentId = a.InsuranceMonthlyPaymentId
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      LEFT JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeAch
      AND (@endorsementSelected = CAST(1 AS BIT)
      AND ict.Code = 'C03') AND (TypeId = 1 OR TypeId = 2)-- only for  { id: 1, name: 'DEBIT' },{ id: 2, name: 'CREDIT' },

      UNION ALL
      -- endorsement payment 
      SELECT
        *
      FROM (SELECT
          4 [Index]
         ,6 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'ADJUSTMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING DAILY - ADJUSTMENT ' +
          CASE
            WHEN ipt.Code = @insurancePaymentTypeCodeCash THEN 'CASH'
            ELSE 'ACH'
          END [Description]
         ,1 [Transactions]
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) >= 0 THEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL)
            ELSE NULL
          END Debit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) < 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL)) * -1
            ELSE NULL
          END Credit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) >= 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) * -1)
            ELSE (([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) * -1))
          END [Balance]
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsurancePaymentType ipt
          ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
        INNER JOIN InsuranceCommissionType ict
          ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ValidatedBy IS NOT NULL
        AND (@endorsementSelected = CAST(1 AS BIT)
        AND ict.Code = 'C03')) qa2
      WHERE (qa2.Debit <> 0
      OR qa2.Credit <> 0)

	  UNION ALL

	  -- Monthly payments policyRenewal commission provider
      SELECT
        5 [Index]
       ,5 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
        ,'COMMISSION PROVIDER' [Type]
       ,'CLOSING DAILY – COMMISSION PROVIDER' [Description]
       ,COUNT(*) [Transactions]
       ,SUM(i.CommissionUsd) [Debit]
       ,NULL [Credit]
       ,SUM(ISNULL(i.CommissionUsd * -1, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (@policyRenewalSelected = CAST(1 AS BIT)
       AND ict.Code = 'C02')
	    AND i.CommissionUsd > 0
      Group BY CAST(i.CreationDate AS Date)
              ,ict.Description



      UNION ALL
      -- Monthly payment cash policyRenewal
      SELECT
        5 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - CASH PAYMENT' [Description]
       ,1 [Transactions]
       ,i.ValidatedUSD [Debit]
       ,NULL [Credit]
       ,(i.ValidatedUSD * -1) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeCash
      AND (@policyRenewalSelected = CAST(1 AS BIT)
      AND ict.Code = 'C02')

      UNION ALL
      -- Monthly payment ach policyRenewal
      SELECT
        5 [Index]
       ,6 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(a.CreationDate, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - ACH PAYMENT' [Description]
       ,1 [Transactions]
       ,CASE
          WHEN a.TypeId = 1 THEN a.USD
          ELSE 0
        END [Debit]
       ,CASE
          WHEN a.TypeId = 1 THEN 0
          ELSE a.USD
        END [Credit]
       ,CASE
          WHEN a.TypeId = 1 THEN (a.USD * -1)
          ELSE a.USD
        END [Balance]
      FROM dbo.InsuranceAchPayment a
      INNER JOIN [dbo].[InsuranceMonthlyPayment] i
        ON i.InsuranceMonthlyPaymentId = a.InsuranceMonthlyPaymentId
      INNER JOIN dbo.InsurancePolicy ii
        ON ii.InsurancePolicyId = i.InsurancePolicyId
      LEFT JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      INNER JOIN InsuranceCommissionType ict
        ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeAch
      AND (@policyRenewalSelected = CAST(1 AS BIT)
      AND ict.Code = 'C02') AND (TypeId = 1 OR TypeId = 2)-- only for  { id: 1, name: 'DEBIT' },{ id: 2, name: 'CREDIT' },

      UNION ALL
      -- policyRenewal payment 
      SELECT
        *
      FROM (SELECT
          5 [Index]
         ,6 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'ADJUSTMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING DAILY - ADJUSTMENT ' +
          CASE
            WHEN ipt.Code = @insurancePaymentTypeCodeCash THEN 'CASH'
            ELSE 'ACH'
          END [Description]
         ,1 [Transactions]
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) >= 0 THEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL)
            ELSE NULL
          END Debit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) < 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL)) * -1
            ELSE NULL
          END Credit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) >= 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) * -1)
            ELSE (([dbo].[fn_CalculateInsuranceAdjustment](NULL, i.InsuranceMonthlyPaymentId, NULL) * -1))
          END [Balance]
        FROM [dbo].[InsuranceMonthlyPayment] i
        INNER JOIN dbo.InsurancePolicy ii
          ON ii.InsurancePolicyId = i.InsurancePolicyId
        INNER JOIN dbo.InsurancePaymentType ipt
          ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
        INNER JOIN InsuranceCommissionType ict
          ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (ii.ProviderId = @ProviderId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ValidatedBy IS NOT NULL
        AND (@policyRenewalSelected = CAST(1 AS BIT)
        AND ict.Code = 'C02')) qa2
      WHERE (qa2.Debit <> 0
      OR qa2.Credit <> 0)


      -- Insurance registration

      UNION ALL

      --Insurance registration
      SELECT
        3 [Index]
       ,4 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'REGISTRATION RELEASE (S.O.S)' [Type]
       ,'CLOSING DAILY' [Description]
       ,COUNT(*) [Transactions]
       ,NULL [Debit]
       ,SUM(ISNULL(i.USD, 0)) [Credit]
       ,SUM(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceRegistration] i
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND i.ProviderId = @ProviderId
      AND @sosSelected = CAST(1 AS BIT)
      Group BY CAST(i.CreationDate AS Date)

      UNION ALL
      -- Insurance registration cash payments
      SELECT
        3 [Index]
       ,5 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - CASH PAYMENT' [Description]
       ,1 [Transactions]
       ,i.ValidatedUSD [Debit]
       ,NULL [Credit]
       ,(i.ValidatedUSD * -1) [Balance]
      FROM [dbo].[InsuranceRegistration] i
      INNER JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeCash
      AND i.ProviderId = @ProviderId
      AND @sosSelected = CAST(1 AS BIT)

      UNION ALL
      -- Insurance registration ach payments
      SELECT
        3 [Index]
       ,5 [Group]
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,'PAYMENT ' + FORMAT(a.CreationDate, 'MM-dd-yyyy') [Type]
       ,'CLOSING DAILY - ACH PAYMENT' [Description]
       ,1 [Transactions]
       ,CASE
          WHEN a.TypeId = 1 THEN a.USD
          ELSE 0
        END [Debit]
       ,CASE
          WHEN a.TypeId = 1 THEN 0
          ELSE a.USD
        END [Credit]
       ,CASE
          WHEN a.TypeId = 1 THEN (a.USD * -1)
          ELSE a.USD
        END [Balance]
      FROM dbo.InsuranceAchPayment a
      INNER JOIN [dbo].[InsuranceRegistration] i
        ON i.InsuranceRegistrationId = a.InsuranceRegistrationId
      LEFT JOIN dbo.InsurancePaymentType ipt
        ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND ipt.Code = @insurancePaymentTypeCodeAch
      AND i.ProviderId = @ProviderId
      AND @sosSelected = CAST(1 AS BIT) AND (TypeId = 1 OR TypeId = 2)-- only for  { id: 1, name: 'DEBIT' },{ id: 2, name: 'CREDIT' },

      UNION ALL
      -- Insurance registration Adjustment
      SELECT
        *
      FROM (SELECT
          3 [Index]
         ,5 [Group]
         ,CAST(i.CreationDate AS Date) AS [Date]
         ,'ADJUSTMENT ' + FORMAT(i.ValidatedOn, 'MM-dd-yyyy') [Type]
         ,'CLOSING DAILY - ADJUSTMENT ' +
          CASE
            WHEN ipt.Code = @insurancePaymentTypeCodeCash THEN 'CASH'
            ELSE 'ACH'
          END [Description]
         ,1 [Transactions]
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId) >= 0 THEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId)
            ELSE NULL
          END Debit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId) < 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId)) * -1
            ELSE NULL
          END Credit
         ,CASE
            WHEN [dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId) >= 0 THEN ([dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId) * -1)
            ELSE (([dbo].[fn_CalculateInsuranceAdjustment](NULL, NULL, i.InsuranceRegistrationId) * -1))
          END [Balance]
        FROM [dbo].[InsuranceRegistration] i
        INNER JOIN dbo.InsurancePaymentType ipt
          ON ipt.InsurancePaymentTypeId = i.InsurancePaymentTypeId
        WHERE (i.CreatedInAgencyId = @AgencyId)
        AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
        AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
        AND i.ValidatedBy IS NOT NULL
        AND i.ProviderId = @ProviderId
        AND @sosSelected = CAST(1 AS BIT)) qa3
      WHERE (qa3.Debit <> 0
      OR qa3.Credit <> 0)) q

    ORDER BY CAST(q.Date AS Date), q.[Index], q.[Group]

  RETURN;
END;







GO