SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-06-11 Jt/6585: Promotional code - Normalizar UPPERCASE en el input CODE


CREATE PROCEDURE [dbo].[sp_GetPromotionalCodeStatusByCodeByPhone]
(@Code      CHAR(4)     = NULL,
@Date Datetime     = NULL
)
AS
     BEGIN
  IF EXISTS (SELECT
    1
  FROM PromotionalCodesStatus P
  INNER JOIN PromotionalCodes pc
    ON pc.PromotionalCodeId = P.PromotionalCodeId
  WHERE P.Code COLLATE Latin1_General_CS_AS = @Code
    AND pc.Reusable = 0
  AND (CAST(@Date AS DATE) >= CAST(pc.FromDate AS DATE))
  AND (CAST(@Date AS DATE) <= CAST(pc.ToDate AS DATE)))

BEGIN
SELECT
  P.PromotionalCodeStatusId
 ,pc.PromotionalCodeId
 ,P.Code
 ,P.Used
 ,P.UsedDate
 ,p.AgencyUsedId
 ,pc.Description
 ,pc.Usd
 ,pc.ToDate
 ,p.UserUsedId
 ,a.Name AgencyUsedName
 ,pc.Reusable
FROM PromotionalCodesStatus P
LEFT JOIN PromotionalCodes pc
  ON pc.PromotionalCodeId = P.PromotionalCodeId
LEFT JOIN Agencies a
  ON A.AgencyId = p.AgencyUsedId
WHERE P.Code COLLATE Latin1_General_CS_AS = @Code;
END;
ELSE
BEGIN
SELECT
  NULL PromotionalCodeStatusId
 ,pc.PromotionalCodeId
 ,pc.Code
 ,NULL Used
 ,NULL UsedDate
 ,NULL AgencyUsedId
 ,pc.Description
 ,pc.Usd
 ,pc.ToDate
 ,NULL UserUsedId
 ,NULL AgencyUsedName
 ,pc.Reusable
FROM PromotionalCodes pc

WHERE Pc.Code COLLATE Latin1_General_CS_AS = @Code  
  AND (CAST(@Date AS DATE) >= CAST(pc.FromDate AS DATE))
  AND (CAST(@Date AS DATE) <= CAST(pc.ToDate AS DATE))
END;
END;
GO