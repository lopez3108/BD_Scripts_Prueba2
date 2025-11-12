SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPromotionalCodesByCode]
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
         UNION ALL
         SELECT Code
         FROM PromotionalCodesStatus
         WHERE Code = @Code
               OR @Code IS NULL;
     END;
GO