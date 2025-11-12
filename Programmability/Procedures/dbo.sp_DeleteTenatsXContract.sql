SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/24-09-2025 task 6750 Ligar ids(documents) a tennants

CREATE PROCEDURE [dbo].[sp_DeleteTenatsXContract] 
 @TenantsXcontractId INT,
    @TenantId INT
AS
BEGIN


   SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM TenantsXcontracts
        WHERE TenantsXcontractId = @TenantsXcontractId;

        DELETE FROM Tenants
        WHERE TenantId = @TenantId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Re-lanzar el error para manejarlo en C#
        THROW;
    END CATCH;
END;
GO