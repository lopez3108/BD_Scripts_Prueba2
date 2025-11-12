SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-06-24 DJ/5923: City sticker created from Title and Plates form
-- 2025-06-09 JF/6571: Guardar valor de descuento aplicado en el momento del registro y no por referencia a configuración

CREATE PROCEDURE [dbo].[sp_GetAllCityStickers]
(@CreationDate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT = NULL
)
AS
     BEGIN
         SELECT c.*,
                ISNULL(p.PromotionalCodeStatusId, 0) PromotionalCodeStatusId,
                ISNULL(p.PromotionalCodeId, 0) PromotionalCodeId,
                ISNULL(p.Usd, 0) UsdDiscount,
                ISNULL(c.ExpenseId, 0) ExpenseCityStickersId,
                ISNULL(c.CashierCommission, 0) CashierCommissionCityStickers,
                --CAST(ISNULL(
                --           (
                --               SELECT TOP 1 1
                --               FROM PromotionalCodesStatus P
                --               WHERE P.CityStickerId = CityStickers.CityStickerId
                --           ), 0) AS VARCHAR(10)) NumberPromotionalCode
				c.UpdatedOn,
				c.UpdatedBy,
         usu.Name UpdatedByName,
		 c.TitleParentId,
		 t.Name as TitleName
         FROM CityStickers c
              LEFT JOIN PromotionalCodesStatus P ON c.CityStickerId = p.CityStickerId
              LEFT JOIN PromotionalCodes pc ON pc.PromotionalCodeId = p.PromotionalCodeId
			   LEFT JOIN Users usu ON c.UpdatedBy = usu.UserId
			   LEFT JOIN dbo.Titles t ON t.TitleId = c.TitleParentId
         WHERE(CAST(c.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND c.AgencyId = @AgencyId
              AND (c.CreatedBy = @UserId OR @UserId IS NULL);
     END;


GO