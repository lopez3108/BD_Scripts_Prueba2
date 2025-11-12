SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[FN_GetContractTenantInfo](@ContractId INT)
RETURNS @result TABLE
(ContractId INT,
 Name     VARCHAR(50),
  Telephone     VARCHAR(15)
)
AS
     BEGIN
        

		 DECLARE @Name varchar(50)
		 set @Name = (select TOP 1 ten.Name 
            FROM TenantsXcontracts tc INNER JOIN Tenants ten ON TC.TenantId  = ten.TenantId
			INNER JOIN Contract con ON TC.ContractId = con.ContractId
			where con.ContractId = @ContractId AND tc.Principal = 1)

					 DECLARE @Telephone varchar(15)
		 set @Telephone = (select TOP 1 ten.Telephone 
            FROM TenantsXcontracts tc INNER JOIN Tenants ten ON TC.TenantId  = ten.TenantId
			INNER JOIN Contract con ON TC.ContractId = con.ContractId
			where con.ContractId = @ContractId AND tc.Principal = 1)


         INSERT INTO @result
         (ContractId,
          Name,
          Telephone
         )
		 VALUES(@ContractId,@Name, @Telephone)
              
         RETURN;
     END;
GO