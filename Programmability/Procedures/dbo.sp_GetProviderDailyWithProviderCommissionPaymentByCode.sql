SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderDailyWithProviderCommissionPaymentByCode]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @Code         VARCHAR(10)
)
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                                 --AND P.Active = 1
                                             AND pt.Code = @Code
              INNER JOIN ProviderCommissionPayments pc ON pc.ProviderId = p.ProviderId
                                                          AND (pc.Year = @YearDate
                                                               AND pc.Month = @MonthDate)
                                                          AND pc.AgencyId = @AgencyId;
     END;
GO