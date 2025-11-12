SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetProviderServicesXProvider] @ProviderId INT = NULL
AS
     BEGIN
         SELECT p.ProviderServiceXProviderId,
                p.ProviderId,
                p.ProviderServiceId,				
                ps.Code,
                ps.Description,
				ps.Translate,
				p.ProviderServiceId ProviderService,
				ps.Code ProviderServiceCode,
				ps.Translate ProviderServiceTranslate,
				--ISNULL(pro.AcceptNegative , 0)AcceptNegative,
				ISNULL(pro.DetailedTransaction , 0) DetailedTransaction,
				CASE  WHEN ps.Code = 'C01'--MONEY TRANSFER-SEND (EN RAZON DE LA CONFIGURACION) TASK 5062 
				THEN CAST(pro.AcceptNegative AS bit)
				WHEN ps.Code = 'C02' OR ps.Code = 'C05'-- MONEY TRANSFER-PAYOUT (SOLO ACEPTA POR DEFAULT NEGATIVOS) TASK 5062 
				THEN CAST(1 AS bit)
				WHEN ps.Code = 'C03' OR ps.Code = 'C04' -- BILL PAYMENTS y TOP-UP PAYMENTS (SOLO ACEPTA POR DEFAULT POSITIVOS) TASK 5062 
				THEN CAST(0 AS bit)			
				END
				AS AcceptNegative,
				CASE  WHEN ps.Code = 'C02' OR ps.Code = 'C05'-- MONEY TRANSFER-PAYOUT (SOLO ACEPTA POR DEFAULT NEGATIVOS) TASK 5062 
				THEN CAST(1 AS bit)
				WHEN ps.Code = 'C01' OR ps.Code = 'C03' OR ps.Code = 'C04' --MONEY TRANSFER-SEND (EN RAZON DE LA CONFIGURACION) TASK 5062
				THEN CAST(0 AS bit)						-- BILL PAYMENTS y TOP-UP PAYMENTS (SOLO ACEPTA POR DEFAULT POSITIVOS) TASK 5062 
				END
				AS OnlyNegative
         FROM dbo.ProviderServicesXProviders p
              INNER JOIN dbo.ProvidersServices ps ON ps.ProviderServiceId = p.ProviderServiceId
			  INNER JOIN Providers pro ON pro.ProviderId = p.ProviderId
			  
         WHERE p.ProviderId =  @ProviderId or @ProviderId is null;
     END;
GO