SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create   FUNCTION [dbo].[fn_GetTenantsNamePrincipal](
@ApartmentsId   INT)
RETURNS VARCHAR(300)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
          DECLARE @Name varchar(80)
		 set @Name = (select ten.Name 
            FROM TenantsXcontracts tc INNER JOIN Tenants ten ON TC.TenantId  = ten.TenantId
			INNER JOIN Contract con ON TC.ContractId = con.ContractId
			INNER JOIN Apartments APART ON APART.ApartmentsId = con.ApartmentId 
			where tc.Principal = cast(1 as bit )  AND APART.ApartmentsId = @ApartmentsId)
		RETURN @Name

            
        
			
			

     END;
GO