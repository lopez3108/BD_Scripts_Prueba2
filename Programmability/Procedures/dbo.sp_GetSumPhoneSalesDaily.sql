SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumPhoneSalesDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT = NULL
)
AS
     BEGIN
         SELECT ISNULL(ISNULL(SUM(p.SellingValue), 0) + (ISNULL(SUM(p.SellingValue), 0) * (SUM(ISNULL(p.Tax, 0))  / count(p.PhoneSalesId)) / 100), 0) Suma
         FROM PhoneSales p
              INNER JOIN InventoryByAgency ia ON p.InventoryByAgencyId = IA.InventoryByAgencyId
              INNER JOIN Inventory i ON i.InventoryId = IA.InventoryId
              LEFT JOIN PhonePlans pp ON pp.PhonePlanId = p.PhonePlanId
         WHERE(CAST(p.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND ia.AgencyId = @AgencyId
              AND (p.CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO