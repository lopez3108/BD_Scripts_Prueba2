SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetProvidersMoneyTransferWithCommissionByProviderId] @Creationdate DATE = NULL,
                                                                               @AgencyId     INT,
                                                                               @ProviderId   INT,
																			   @IsForex   BIT = NULL
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT TOP 1 p.ProviderId,
                      p.Name,
                      p.Active,
                      p.ProviderTypeId,
                      p.AcceptNegative,
                      0 AS 'Disabled',
                      0 Comision,
                      pt.Code AS ProviderTypeCode,
                      pt.Description AS ProviderType,
                      ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                             AND P.Active = 1
              INNER JOIN ProviderCommissionPayments pc ON pc.ProviderId = p.ProviderId
                                                          AND (pc.Year = @YearDate
                                                               AND pc.Month = @MonthDate)
                                                          AND pc.AgencyId = @AgencyId
         WHERE pt.Code = 'C02'  AND p.ProviderId = @ProviderId
		 AND (@IsForex IS NULL OR pc.IsForex = @IsForex)
         ORDER BY Name;
     END;
GO