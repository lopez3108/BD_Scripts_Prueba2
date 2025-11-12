SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscountPlateSticker] (@DiscountPlateStickerId INT = NULL,
@Usd DECIMAL(18, 2),
--@Quantity               INT,
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
  --SET @DiscountPlateStickerId =
  --(
  --    SELECT d.DiscountPlateStickerId
  --    FROM DiscountPlateStickers d
  --    WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
  --         AND d.AgencyId = @AgencyId
  --         AND d.CreatedBy = @CreatedBy
  --);
  IF (@DiscountPlateStickerId IS NULL)
  BEGIN
    INSERT INTO [dbo].DiscountPlateStickers (Usd,

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
    UPDATE [dbo].DiscountPlateStickers
    SET Usd = @Usd
       ,LastUpdatedBy = @LastUpdatedBy
       ,LastUpdatedOn = @LastUpdatedOn
       ,ActualClientTelephone = @ActualClientTelephone
       ,TelIsCheck = @TelIsCheck
    WHERE DiscountPlateStickerId = @DiscountPlateStickerId;
    SET @IdCreated = 0;
  END;
END;
GO