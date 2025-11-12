SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDiscountCityStickersDaily] (@Creationdate DATE = NULL,
@AgencyId INT,
@UserId INT = NULL)
AS
BEGIN
  SELECT
    d.DiscountCityStickerId
   ,d.Usd
   ,d.CreationDate
   ,d.CreatedBy
   ,d.AgencyId
   ,d.Discount
   ,d.LastUpdatedOn
   ,d.LastUpdatedBy
   ,ISNULL(d.TelIsCheck, CAST(0 AS BIT)) TelIsCheck
   ,d.ActualClientTelephone
   ,usu.Name LastUpdatedByName
  FROM DiscountCityStickers d
  LEFT JOIN Users usu
    ON d.LastUpdatedBy = usu.UserId
  INNER JOIN Users us
    ON d.CreatedBy = us.UserId
  WHERE (CAST(d.CreationDate AS DATE) = CAST(@Creationdate AS DATE)
  OR @Creationdate IS NULL)
  AND d.AgencyId = @AgencyId
  AND (d.CreatedBy = @UserId
  OR @UserId IS NULL);
END;
GO