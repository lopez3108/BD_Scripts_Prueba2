SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPhoneSalesDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT
)
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT p.PhoneSalesId,
                I.InventoryId,
                p.CardPayment,
                p.CardPaymentFee,
                p.CreationDate,
                p.CreatedBy,
                p.Imei,
                P.OnlyPhone,
                i.Model,
                ia.InStock,
                ia.InventoryByAgencyId,
                p.PurchaseValue,
                p.SellingValue,
				isnull(p.Cash, 0)Cash,
                p.SellingValue 'moneyvalue',
                p.SellingValue 'Value',
                'true' 'Disabled',
                'true' 'Set',
                isnull(p.PhonePlanId, 0) PhonePlanId,
                isnull(pp.Usd, 0) PhonePlanUsd,
                isnull(p.Tax, 0) Tax,
                Description+' - '+'$'+CONVERT(VARCHAR(12), CAST(pp.Usd AS MONEY), 1) AS DescriptionUsd,
                (ISNULL(
                       (
                           SELECT ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
                           FROM Providers p
                                INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                                 --AND P.Active = 1
                                                               AND pt.Code = 'C12'
                                INNER JOIN ProviderCommissionPayments pc ON pc.ProviderId = p.ProviderId
                                                                            AND (pc.Year = @YearDate
                                                                                 AND pc.Month = @MonthDate)
                                                                            AND pc.AgencyId = @AgencyId
                       ), 0)) AS ProviderCommissionPaymentId,
					    p.LastUpdatedOn,
         usu.Name LastUpdatedByName,
		 p.LastUpdatedBy
         FROM PhoneSales p
              INNER JOIN InventoryByAgency ia ON p.InventoryByAgencyId = IA.InventoryByAgencyId
              INNER JOIN Inventory i ON i.InventoryId = IA.InventoryId
			  LEFT JOIN Users usu ON p.LastUpdatedBy = usu.UserId
              LEFT OUTER JOIN PhonePlans pp ON pp.PhonePlanId = p.PhonePlanId
         WHERE(CAST(p.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND ia.AgencyId = @AgencyId
              AND p.CreatedBy = @UserId;
     END;
GO