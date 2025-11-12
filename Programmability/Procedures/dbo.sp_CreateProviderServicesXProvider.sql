SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateProviderServicesXProvider]

@ProviderId INT,
@ProviderServiceId INT
AS 

BEGIN

INSERT INTO [dbo].[ProviderServicesXProviders]
           ([ProviderId]
           ,ProviderServiceId)
     VALUES
           (@ProviderId
           ,@ProviderServiceId)

		   SELECT @@IDENTITY


	END

GO