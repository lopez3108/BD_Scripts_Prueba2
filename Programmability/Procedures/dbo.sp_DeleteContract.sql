SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/24-09-2025 task 6750 Ligar ids(documents) a tennants

CREATE PROCEDURE [dbo].[sp_DeleteContract]
 (
		@ContractId int,
		@Date DATETIME

    )
AS 

BEGIN

DECLARE @creationDate DATETIME
SET @creationDate = (SELECT TOP 1 CreationDate FROM [Contract] WHERE ContractId = @ContractId)

IF((CAST(@Date as DATE) = CAST(@creationDate as DATE)) AND 
(CAST([dbo].[fn_GetCheckContractPayments](@ContractId) as BIT) = CAST(0 as BIT)))
BEGIN

  -- 1. Guardar los TenantId relacionados a este contrato
        DECLARE @TenantsToDelete TABLE (TenantId INT);

        INSERT INTO @TenantsToDelete (TenantId)
        SELECT DISTINCT TenantId
        FROM dbo.TenantsXcontracts
        WHERE ContractId = @ContractId;

 -- 2. Borrar registros relacionados al contrato

DELETE dbo.TermsXContract WHERE ContractId = @ContractId
DELETE dbo.ContractNotes WHERE ContractId = @ContractId
DELETE dbo.TenantsXcontracts WHERE ContractId = @ContractId
DELETE dbo.RentPayments WHERE ContractId = @ContractId
DELETE dbo.DepositFinancingPayments WHERE ContractId = @ContractId

-- 3. Borrar el contrato
DELETE [Contract] WHERE ContractId = @ContractId

  -- 4. Borrar los Tenants que ya no tengan más contratos
        DELETE T
        FROM dbo.Tenants T
        INNER JOIN @TenantsToDelete TD ON T.TenantId = TD.TenantId
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.TenantsXcontracts TXC
            WHERE TXC.TenantId = T.TenantId
        );

SELECT @ContractId

END
ELSE
BEGIN

SELECT -1

END


	END

GO