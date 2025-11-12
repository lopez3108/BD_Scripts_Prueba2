SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAgencyProvidersByNumber] @AgencyId            INT,
													  @IncludeVentra BIT = NULL, 
                                                      @IncludeBillPayments BIT = NULL,
													  @Active BIT = NULL
AS
    BEGIN
        DECLARE @Prov TABLE
        (ProviderId INT NOT NULL, 
         Name       VARCHAR(50)
        );
        INSERT INTO @Prov
               SELECT dbo.Providers.ProviderId, 
                      dbo.Providers.Name + ' - ' + dbo.MoneyTransferxAgencyNumbers.Number AS Name
               FROM dbo.Providers
                    INNER JOIN dbo.MoneyTransferxAgencyNumbers ON dbo.Providers.ProviderId = dbo.MoneyTransferxAgencyNumbers.ProviderId
               WHERE (AgencyId = @AgencyId) AND ( dbo.Providers.Active=@Active OR @Active IS NULL)
               ORDER BY Name;
		IF(@IncludeVentra IS NOT NULL)
            BEGIN
                IF(@IncludeVentra = 1)
                    BEGIN
                        INSERT INTO @Prov
                               SELECT dbo.Providers.ProviderId, 
                                      dbo.Providers.Name

                               FROM dbo.Providers
                                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                               WHERE (dbo.ProviderTypes.Code = 'C20') AND ( dbo.Providers.Active=@Active OR @Active IS NULL)
                               ORDER BY Name;
                END;
        END;

        IF(@IncludeBillPayments IS NOT NULL)
            BEGIN
                IF(@IncludeBillPayments = 1)
                    BEGIN
                        INSERT INTO @Prov
                               SELECT dbo.Providers.ProviderId, 
                                      dbo.Providers.Name

                               FROM dbo.Providers
                                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                               WHERE (dbo.ProviderTypes.Code = 'C01') AND ( dbo.Providers.Active=@Active OR @Active IS NULL)
                               ORDER BY Name;
                END;
        END;
        SELECT *
        FROM @Prov
        ORDER BY Name;
    END;
GO