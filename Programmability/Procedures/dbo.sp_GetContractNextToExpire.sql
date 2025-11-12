SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GetContractNextToExpire] 

@CurrentDate DATETIME,
@Days INT

AS
     BEGIN

SELECT        
dbo.Contract.ContractId, 
dbo.Apartments.Number as ApartmentNumber, 
dbo.Properties.Name as PropertyName, 
dbo.Tenants.Name AS TenantId, 
dbo.Tenants.Name AS TenantName,
dbo.Tenants.Telephone AS Telephone,
dbo.Contract.StartDate, 
dbo.Contract.EndDate,
DATEDIFF(day, @CurrentDate, dbo.Contract.EndDate) as DaysToExpire,
(SELECT TOP 1 Message FROM FinancingMessages WHERE Title = 'CONTRACT NEXT TO EXPIRE') as ExpiredMessage,
(SELECT TOP 1 FinancingMessageId FROM FinancingMessages WHERE Title = 'CONTRACT NEXT TO EXPIRE') as FinancingMessageId,
(SELECT TOP 1 SMSCategoryId FROM FinancingMessages WHERE Title = 'CONTRACT NEXT TO EXPIRE') as MessageCategoryId,
(SELECT TOP 1 AgencyId FROM Agencies WHERE Agencies.AgencyId = dbo.Contract.AgencyId) as AgencyId,
(SELECT TOP 1 Name FROM Agencies WHERE Agencies.AgencyId = dbo.Contract.AgencyId) as AgencyName,
(SELECT TOP 1 Telephone FROM Agencies WHERE Agencies.AgencyId = dbo.Contract.AgencyId) as AgencyPhone,
dbo.Contract.CreatedBy as AdminId
FROM            dbo.Contract INNER JOIN
                         dbo.Apartments ON dbo.Contract.ApartmentId = dbo.Apartments.ApartmentsId INNER JOIN
                         dbo.Properties ON dbo.Apartments.PropertiesId = dbo.Properties.PropertiesId 
						 INNER JOIN  dbo.TenantsXcontracts AS TC ON TC.ContractId= dbo.Contract.ContractId AND TC.Principal = 1
						 INNER JOIN dbo.Tenants  on dbo.Tenants.TenantId = TC.TenantId

						 --INNER JOIN dbo.Tenants ON dbo.Contract.TenantId = dbo.Tenants.TenantId

						  WHERE DATEDIFF(day, @CurrentDate, dbo.Contract.EndDate) = @Days

  END
GO