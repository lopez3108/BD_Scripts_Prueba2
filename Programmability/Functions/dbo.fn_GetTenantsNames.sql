SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetTenantsNames](
@ApartmentsId   INT)
RETURNS VARCHAR(300)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN

	 DECLARE @validContractId INT
	 SET @validContractId = (SELECT TOP 1 ContractStatusId FROM ContractStatus WHERE Code = 'C01')

	 IF(EXISTS(SELECT * FROM dbo.Contract WHERE ApartmentId = @ApartmentsId AND Status = @validContractId))
	 BEGIN

	 DECLARE @contractId INT
	 SET @contractId = (SELECT TOP 1 ContractId FROM dbo.Contract WHERE ApartmentId = @ApartmentsId AND Status = @validContractId)

	 RETURN (SELECT TOP 1 Name FROM Tenants t INNER JOIN TenantsXcontracts tc on tc.TenantId = t.TenantId AND tc.ContractId = @contractId)


	 END
	 ELSE
	 BEGIN

	 RETURN NULL


	 END
         
		  RETURN NULL

		--RETURN (SELECT  STUFF((SELECT  ',' + Name
  --          FROM TenantsXcontracts tc INNER JOIN Tenants ten ON TC.TenantId  = ten.TenantId
		--	INNER JOIN Contract con ON TC.ContractId = con.ContractId
		--	INNER JOIN Apartments APART ON APART.ApartmentsId = con.ApartmentId AND APART.ApartmentsId = @ApartmentsId

            
  --          FOR XML PATH(''), TYPE).value('text()[1]','nvarchar(max)')
  --         , 1, LEN(','), '') AS listStr)
			
			

     END;
GO