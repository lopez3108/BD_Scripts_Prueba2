SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATED BY JOHAN
--CREATED ON 10/5/2023
--ELIMINAR PROVIDERS SERVICES
create PROCEDURE [dbo].[sp_DeleteProviderServicesXProvider]

@ProviderId INT
AS 

BEGIN

DELETE [dbo].[ProviderServicesXProviders] WHERE ProviderId = @ProviderId

SELECT @ProviderId

	END

GO