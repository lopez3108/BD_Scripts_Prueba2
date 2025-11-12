SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateTenatsXContract] @ContractId     INT, 
                                                
                                                @TenantId          INT, 
                                                @TenantsXcontractId INT = NULL, 
												@Principal BIT = NULL, 
                                                @IdSaved        INT OUTPUT
AS
    BEGIN
        IF(@TenantsXcontractId IS NULL)
            BEGIN
INSERT INTO [dbo].TenantsXcontracts ([ContractId],
TenantId, Principal)
	VALUES (@ContractId, @TenantId, @Principal);
SET @IdSaved = @@IDENTITY;
            END;
ELSE
BEGIN
UPDATE [dbo].TenantsXcontracts
SET ContractId = @ContractId
   ,TenantId = @TenantId, Principal = @Principal
WHERE TenantsXcontractId = @TenantsXcontractId;
SET @IdSaved = @TenantsXcontractId;
            END;
END;
GO