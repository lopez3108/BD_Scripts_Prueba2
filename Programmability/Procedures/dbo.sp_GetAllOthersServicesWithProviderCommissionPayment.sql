SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllOthersServicesWithProviderCommissionPayment] @Creationdate   DATE = NULL,
                                                                             @AgencyId       INT  = NULL,
                                                                             @OtherServiceId INT  = NULL,
                                                                             @CreatedBy      INT  = NULL
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT DISTINCT
                OtherId,
                Name,
                AcceptNegative AcceptZero,
                AcceptNegative,
                AcceptDetails AS 'Disabled',
                AcceptDetails,
			 		   CAST(1 AS BIT) Valid,
                '0.00' AS 'moneyvalue',
                (ISNULL(
                       (
                           SELECT ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
                           FROM Providers p
                                INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                                 --AND P.Active = 1
                                                               AND pt.Code = 'C07'
                                INNER JOIN ProviderCommissionPayments pc ON pc.ProviderId = p.ProviderId
                                                                            AND (pc.Year = @YearDate
                                                                                 AND pc.Month = @MonthDate)
                                                                            AND pc.AgencyId = @AgencyId
                       ), 0)) AS ProviderCommissionPaymentId
         FROM OthersServices o
              LEFT JOIN OthersDetails od ON O.OtherId = OD.OtherServiceId
         WHERE(OtherId = @OtherServiceId
               OR @OtherServiceId IS NULL)
              AND ((OD.CreatedBy = @CreatedBy
                    AND OD.AgencyId = @AgencyId
                    AND CAST(od.CreationDate AS DATE) = CAST(@Creationdate AS DATE))
                   OR o.Active = 1)
         ORDER BY Name;
     END;
GO