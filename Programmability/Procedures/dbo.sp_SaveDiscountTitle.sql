SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscountTitle] (@DiscountTitleId INT = NULL,
@TitleId INT,
@Discount DECIMAL(18, 2),
@Usd DECIMAL(18, 2),
@ReasonId INT,
@OtherReason VARCHAR(50) = NULL,
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT,
@IdCreated INT OUTPUT,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@ActualClientTelephone VARCHAR(10),
@TelIsCheck BIT = NULL)
AS
BEGIN
  IF (@DiscountTitleId IS NULL)
  BEGIN
    INSERT INTO [dbo].DiscountTitles (TitleId,
    ReasonId,
    OtherReason,
    Discount,
    Usd,
    CreationDate,
    CreatedBy,
    AgencyId,
    LastUpdatedBy,
    LastUpdatedOn,
    ActualClientTelephone,
    TelIsCheck)
      VALUES (@TitleId, @ReasonId, @OtherReason, @Discount,@Usd, @CreationDate, @CreatedBy, @AgencyId, @LastUpdatedBy, @LastUpdatedOn, @ActualClientTelephone, @TelIsCheck);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].DiscountTitles
    SET TitleId = @TitleId
       ,ReasonId = @ReasonId
       ,OtherReason = @OtherReason
       ,Discount = @Discount
       ,Usd = @Usd
       ,LastUpdatedBy = @LastUpdatedBy
       ,LastUpdatedOn = @LastUpdatedOn
       ,ActualClientTelephone = @ActualClientTelephone
       ,TelIsCheck = @TelIsCheck
    WHERE DiscountTitleId = @DiscountTitleId;
    SET @IdCreated = 0;
  END;
END;
GO