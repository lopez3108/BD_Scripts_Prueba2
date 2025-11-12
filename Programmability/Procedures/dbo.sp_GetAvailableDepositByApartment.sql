SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAvailableDepositByApartment]
 (
      @ApartmentId INT
    )
AS 

BEGIN

declare @available decimal(18,2)
set @available = 0

declare @tenant varchar(300)


IF(EXISTS(SELECT 1 FROM Contract WHERE ApartmentId = @ApartmentId AND Status = 1))
BEGIN

set @available = [dbo].fn_GetContractAvailableDeposit ((SELECT TOP 1 ContractId FROM Contract WHERE ApartmentId = @ApartmentId ))
set @tenant = (select dbo.fn_GetTenantsNames(@ApartmentId))
--(SELECT TOP 1 Name FROM Contract INNER JOIN
--Tenants ON Tenants.TenantId = Contract.TenantId WHERE ApartmentId = @ApartmentId AND Status = 1)


END 


select @available as Available, @tenant as Tenant



	END
GO