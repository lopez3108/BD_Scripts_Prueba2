SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[fn_GetTenantsTelephone](
@ApartmentsId   INT)
RETURNS VARCHAR(300)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
          DECLARE @Telephone varchar(20)
		 set @Telephone = (select ten.Telephone 
            FROM TenantsXcontracts tc INNER JOIN Tenants ten ON TC.TenantId  = ten.TenantId
			INNER JOIN Contract con ON TC.ContractId = con.ContractId
			INNER JOIN Apartments APART ON APART.ApartmentsId = con.ApartmentId 
			where tc.Principal = cast(1 as bit )  AND APART.ApartmentsId = @ApartmentsId)
		RETURN @Telephone

            
        
			
			

     END;
GO