SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--date 20-06-2025 task 6602 Conflicto Lógico en el Registro de Códigos Promocionales JF

CREATE PROCEDURE [dbo].[sp_GetPromotionalCodesByCodeByPromotionalCodeId]
(@Code              CHAR(4) = NULL,
 @PromotionalCodeId INT     = NULL
)
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT Code

         FROM PromotionalCodes
         WHERE(Code = @Code
               OR @Code IS NULL)
              AND (PromotionalCodeId <> @PromotionalCodeId
                   OR @PromotionalCodeId IS NULL)

    UNION

    -- Desde PromotionalCodesStatus
    SELECT Code
    FROM PromotionalCodesStatus
    WHERE (Code = @Code OR @Code IS NULL) 
        AND (Reusable = 0 OR Reusable IS NULL)
        
     END;

GO