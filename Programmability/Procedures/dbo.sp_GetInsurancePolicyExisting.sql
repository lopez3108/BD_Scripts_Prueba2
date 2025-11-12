SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-10-09 DJ/6086: Gets existing policy list by insurance/policy
-- Last update JT/20-10-2024 TASK 6086 fix error searching by policy number 
-- 2024-12-08 JF/6243: Insurance - Add nuevo campo insurance
-- 2025-01-11 DJ/6282: Hacer merge a tareas relaccionadas con el campo D.O.B

CREATE PROCEDURE [dbo].[sp_GetInsurancePolicyExisting]
@PolicyNumber VARCHAR(20),
@InsuranceCompaniesId int = NULL,
@InsurancePolicyId INT = NULL
AS 

BEGIN


SELECT 
	i.InsurancePolicyId
      ,i.[ClientName]
      ,i.[ClientTelephone]
      ,i.[PolicyNumber]
      ,i.[PolicyTypeId]
	  ,p.Name as Provider
	  ,p.ProviderId
	  ,ic.Name as InsuranceCompany
	  ,ic.InsuranceCompaniesId
	  ,pp.Description as PolicyType
	  ,i.ExpirationDate
	  ,i.USD
	  ,i.CreationDate
	  ,i.TelIsCheck
	  ,i.DOB
    ,ISNULL(i.MonthlyPaymentUsd,0) AS MonthlyPaymentUsd
  FROM [dbo].[InsurancePolicy] i
  INNER JOIN dbo.InsuranceCompanies ic ON ic.InsuranceCompaniesId = i.InsuranceCompaniesId
  INNER JOIN dbo.Providers p ON p.ProviderId = i.ProviderId
  INNER JOIN dbo.PolicyType pp ON pp.PolicyTypeId = i.PolicyTypeId
  WHERE 
  (@PolicyNumber IS NULL OR i.PolicyNumber = @PolicyNumber ) AND
  (@InsuranceCompaniesId IS NULL OR i.InsuranceCompaniesId = @InsuranceCompaniesId) AND
  (@InsurancePolicyId IS NULL OR i.InsurancePolicyId <> @InsurancePolicyId)



  END

GO