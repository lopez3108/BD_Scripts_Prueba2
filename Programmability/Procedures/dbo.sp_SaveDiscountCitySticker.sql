SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscountCitySticker] (@DiscountCityStickerId INT = NULL,
@Usd DECIMAL(18, 2),
--@Quantity              INT,
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT,
@Discount DECIMAL(18, 2),
@IdCreated INT OUTPUT,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@ActualClientTelephone VARCHAR(10),
@TelIsCheck BIT = NULL)
AS
BEGIN
  --SET @DiscountCityStickerId =
  --(
  --    SELECT d.DiscountCityStickerId
  --    FROM DiscountCityStickers d
  --    WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
  --         AND d.AgencyId = @AgencyId
  --         AND d.CreatedBy = @CreatedBy
  --);
  IF (@DiscountCityStickerId IS NULL)
  BEGIN
    INSERT INTO [dbo].DiscountCityStickers (Usd,

    CreationDate,
    CreatedBy,
    AgencyId,
    Discount,
    LastUpdatedBy,
    LastUpdatedOn,
    ActualClientTelephone,
    TelIsCheck)
      VALUES (@Usd, @CreationDate, @CreatedBy, @AgencyId, @Discount, @LastUpdatedBy, @LastUpdatedOn, @ActualClientTelephone, @TelIsCheck);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].DiscountCityStickers
    SET Usd = @Usd
       ,LastUpdatedBy = @LastUpdatedBy
       ,LastUpdatedOn = @LastUpdatedOn
       ,ActualClientTelephone = @ActualClientTelephone
       ,TelIsCheck = @TelIsCheck
    WHERE DiscountCityStickerId = @DiscountCityStickerId;
    SET @IdCreated = 0;
  END;
END;
GO