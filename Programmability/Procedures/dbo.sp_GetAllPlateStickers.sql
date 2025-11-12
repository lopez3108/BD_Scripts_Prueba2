SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-09 JF/6571: Guardar valor de descuento aplicado en el momento del registro y no por referencia a configuración

CREATE PROCEDURE [dbo].[sp_GetAllPlateStickers]
(@CreationDate DATE = NULL, 
 @AgencyId     INT, 
 @UserId       INT  = NULL
)
AS
    BEGIN
        SELECT c.*, 
               ISNULL(p.PromotionalCodeStatusId, 0) PromotionalCodeStatusId, 
               ISNULL(p.PromotionalCodeId, 0) PromotionalCodeId, 
               ISNULL(p.Usd, 0) UsdDiscount, 
               ISNULL(c.ExpenseId, 0) ExpensePlateStickerId,
               ISNULL(c.CashierCommission, 0) CashierCommissionPlateSticker,
               c.UpdatedOn, 
			         c.UpdatedBy,
               usu.Name UpdatedByName
        FROM PlateStickers c
             LEFT JOIN PromotionalCodesStatus P ON c.PlateStickerId = p.PlateStickerId
             LEFT JOIN PromotionalCodes pc ON pc.PromotionalCodeId = p.PromotionalCodeId
             LEFT JOIN Users usu ON c.UpdatedBy = usu.UserId
        WHERE(CAST(c.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
              OR @CreationDate IS NULL)
             AND c.AgencyId = @AgencyId
             AND (c.CreatedBy = @UserId
                  OR @UserId IS NULL);
    END;

GO