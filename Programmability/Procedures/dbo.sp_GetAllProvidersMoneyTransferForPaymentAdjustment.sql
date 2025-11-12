SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransferForPaymentAdjustment] @AgencyId   INT = NULL, 
                                                                            @ProviderId INT = NULL, 
                                                                            @Active     BIT = NULL
AS
    BEGIN
        SELECT p.ProviderId, 
               p.Name + ISNULL(
        (
            SELECT TOP 1 ' - ' + Number
            FROM dbo.MoneyTransferxAgencyNumbers
            WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = @AgencyId
                  AND (p.Active = @Active
                       OR @Active IS NULL)
                  AND dbo.MoneyTransferxAgencyNumbers.ProviderId = p.ProviderId
        ), '') AS Name
        FROM Providers p
             INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
			 INNER JOIN MoneyTransferxAgencyNumbers mt ON p.ProviderId = mt.ProviderId
                                                          AND mt.AgencyId = @AgencyId
                                                          OR @AgencyId IS NULL
        WHERE(pt.Code = 'C02'
              OR pt.Code = 'C05')
             AND (p.Active = @Active
                  OR @Active IS NULL)
             AND p.ProviderId = CASE
                                    WHEN @ProviderId IS NULL
                                    THEN p.ProviderId
                                    ELSE @ProviderId
                                END
        ORDER BY Name;
    END;
GO