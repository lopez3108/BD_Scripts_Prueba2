SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAProvidersElsManualWithProviderCommissionPayment] @Creationdate  DATE = NULL,
                                                                          @AgencyId      INT  = NULL,
                                                                          @ProviderElsId INT  = NULL
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT ProviderElsId,
                Code,
                Name,
                AllowFee1Default,
                Fee1Default,
                AllowFee2,
                AllowDefaultUsd,
                DefaultUsd,
                ISNULL(FeeELS, 0) AS FeeELS,
                (ISNULL(
                       (
                           SELECT ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
                           FROM Providers p
                                --INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                                 --AND P.Active = 1
                                                 --AND pt.Code = 'C10' 
                                INNER JOIN ProviderCommissionPayments pc ON pc.ProviderId = p.ProviderId
                                                                            AND (pc.Year = @YearDate
                                                                                 AND pc.Month = @MonthDate)
                                                                            AND pc.AgencyId = @AgencyId
                       ), 0)) AS ProviderCommissionPaymentId
         FROM dbo.ProvidersEls
         WHERE ProviderElsId = @ProviderElsId
               OR @ProviderElsId IS NULL
         ORDER BY Name;
     END;
GO