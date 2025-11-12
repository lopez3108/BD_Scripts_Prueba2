SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 19/11/2024 11:18 p. m.
-- Database:    developing
-- Description: task 6207 Nuevo reporte insurance
-- =============================================

-- 2025-01-15 JF/6287: Ajustes generales INSURANCE

CREATE FUNCTION [dbo].[FN_GenerateInsuranceTransactionsReport] (@AgencyId INT,
@ProviderId INT,
@FromDate DATETIME,
@ToDate DATETIME,
@InsuranceTypeIds VARCHAR(100) = NULL)
RETURNS @Result TABLE (
  [Index] INT
 ,[Group] INT
 ,IdGroup INT
 ,[Date] DATETIME
 ,[Provider] VARCHAR(50)
 ,[PolicyNumber] VARCHAR(50)
 ,[Insurance] VARCHAR(50)
 ,[Type] VARCHAR(40)
 ,[Employee] VARCHAR(70)
 ,[ClientName] VARCHAR(70)
 ,[Transactions] INT
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

  INSERT INTO @Result
    SELECT
      *
    FROM (
      -- New policy
      SELECT
        1 [Index]
       ,4 [Group]
       ,i.InsurancePolicyId IdGroup
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,p.Name AS [Provider]
       ,i.[PolicyNumber]
       ,c.Name AS [Insurance]
       ,'NEW POLICY' [Type]
       ,u.Name AS Employee
       ,i.ClientName AS ClientName
       ,1 AS Transactions
       ,ISNULL(i.USD, 0) [Credit]
       ,(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsurancePolicy] i
      INNER JOIN dbo.Users u
        ON u.UserId = i.CreatedBy
      INNER JOIN dbo.Providers p
        ON p.ProviderId = i.ProviderId
      INNER JOIN dbo.InsuranceCompanies c
        ON c.InsuranceCompaniesId = i.InsuranceCompaniesId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (i.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND i.CreatedByMonthlyPayment = CAST(0 AS BIT) AND @newPolicySelected = CAST(1 AS BIT)

       
      -- Monthly payments

      UNION ALL

      -- Monthly payments
      SELECT
        2 [Index]
       ,4 [Group]
       ,i.InsuranceMonthlyPaymentId IdGroup
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,p.Name AS [Provider]
       ,ii.PolicyNumber
       ,c.Name AS [Insurance]
--       ,'MONTHLY PAYMENT' [Type]
       ,ict.Description [Type]
       ,u.Name AS Employee
       ,ii.ClientName AS ClientName
       ,1 AS Transactions
       ,ISNULL(i.USD, 0) [Credit]
       ,(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii   ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN dbo.Users u  ON u.UserId = i.CreatedBy
      INNER JOIN dbo.Providers p  ON p.ProviderId = ii.ProviderId
      INNER JOIN dbo.InsuranceCompanies c ON c.InsuranceCompaniesId = ii.InsuranceCompaniesId
      INNER JOIN InsuranceCommissionType ict ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date)) AND (@monthlyPaymentSelected = CAST(1 AS BIT) AND ict.Code = 'C04'  )

UNION ALL

      -- endorsement
      SELECT
        4 [Index]
       ,4 [Group]
       ,i.InsuranceMonthlyPaymentId IdGroup
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,p.Name AS [Provider]
       ,ii.PolicyNumber
       ,c.Name AS [Insurance]
--       ,'MONTHLY PAYMENT' [Type]
       ,ict.Description [Type]
       ,u.Name AS Employee
       ,ii.ClientName AS ClientName
       ,1 AS Transactions
       ,ISNULL(i.USD, 0) [Credit]
       ,(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii   ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN dbo.Users u  ON u.UserId = i.CreatedBy
      INNER JOIN dbo.Providers p  ON p.ProviderId = ii.ProviderId
      INNER JOIN dbo.InsuranceCompanies c ON c.InsuranceCompaniesId = ii.InsuranceCompaniesId
      INNER JOIN InsuranceCommissionType ict ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date)) AND (@endorsementSelected = CAST(1 AS BIT) AND ict.Code = 'C03' )

UNION ALL

      -- policyRenewal
      SELECT
        5 [Index]
       ,4 [Group]
       ,i.InsuranceMonthlyPaymentId IdGroup
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,p.Name AS [Provider]
       ,ii.PolicyNumber
       ,c.Name AS [Insurance]
--       ,'MONTHLY PAYMENT' [Type]
      ,ict.Description [Type]
       ,u.Name AS Employee
       ,ii.ClientName AS ClientName
       ,1 AS Transactions
       ,ISNULL(i.USD, 0) [Credit]
       ,(ISNULL(i.USD, 0)) [Balance]
      FROM [dbo].[InsuranceMonthlyPayment] i
      INNER JOIN dbo.InsurancePolicy ii   ON ii.InsurancePolicyId = i.InsurancePolicyId
      INNER JOIN dbo.Users u  ON u.UserId = i.CreatedBy
      INNER JOIN dbo.Providers p  ON p.ProviderId = ii.ProviderId
      INNER JOIN dbo.InsuranceCompanies c ON c.InsuranceCompaniesId = ii.InsuranceCompaniesId
      INNER JOIN InsuranceCommissionType ict ON i.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (ii.ProviderId = @ProviderId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date)) AND (@policyRenewalSelected = CAST(1 AS BIT) AND ict.Code = 'C02' )

   

      -- Insurance registration

      UNION ALL

      --Insurance registration
      SELECT
        3 [Index]
       ,4 [Group]
       ,i.InsuranceRegistrationId IdGroup
       ,CAST(i.CreationDate AS Date) AS [Date]
       ,p.Name AS [Provider]
       ,'-' PolicyNumber
       ,'-' AS [Insurance]
       ,'REGISTRATION RELEASE (S.O.S)' [Type]
       ,u.Name AS Employee
       ,i.ClientName AS ClientName
       ,1 AS Transactions
       ,ISNULL(i.USD, 0) [Credit]
       ,ISNULL(i.USD, 0) [Balance]
      FROM [dbo].[InsuranceRegistration] i
      INNER JOIN dbo.Users u
        ON u.UserId = i.CreatedBy
      INNER JOIN dbo.Providers p
        ON p.ProviderId = i.ProviderId
      WHERE (i.CreatedInAgencyId = @AgencyId)
      AND (CAST(i.CreationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(i.CreationDate AS Date) <= CAST(@ToDate AS Date))
      AND (i.ProviderId = @ProviderId) AND @sosSelected = CAST(1 AS BIT)
    
    ) q

    ORDER BY CAST(q.Date AS Date), q.[Index], q.[Group]

  RETURN;
END;








GO