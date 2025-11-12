SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscountCheck] (@DiscountCheckId INT = NULL,
@CheckNumber VARCHAR(50),
@Usd DECIMAL(18, 2),
@Discount DECIMAL(18, 2),
@ActualClient VARCHAR(50),
@ReferedClient VARCHAR(50) = NULL,
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT,
@IdCreated INT OUTPUT,
@IsActualClient BIT = NULL,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@ActualClientTelephone VARCHAR(10),
@TelIsCheck BIT = NULL,
@Account VARCHAR(50) = NULL)
AS
BEGIN
  IF (@DiscountCheckId IS NULL)
  BEGIN
    INSERT INTO [dbo].DiscountChecks (CheckNumber,
    Usd,
    Discount,
    ActualClient,
    ReferedClient,
    CreationDate,
    CreatedBy,
    AgencyId,
    IsActualClient,
    LastUpdatedBy,
    LastUpdatedOn,
    ActualClientTelephone,
    TelIsCheck,
    Account)
      VALUES (@CheckNumber, @Usd, @Discount, @ActualClient, @ReferedClient, @CreationDate, @CreatedBy, @AgencyId, @IsActualClient, @LastUpdatedBy, @LastUpdatedOn, @ActualClientTelephone, @TelIsCheck, @Account);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].DiscountChecks
    SET CheckNumber = @CheckNumber
       ,Usd = @Usd
       ,Discount = @Discount
       ,ActualClient = @ActualClient
       ,ReferedClient = @ReferedClient
       ,IsActualClient = @IsActualClient
       ,LastUpdatedBy = @LastUpdatedBy
       ,LastUpdatedOn = @LastUpdatedOn
       ,ActualClientTelephone = @ActualClientTelephone
       ,TelIsCheck = @TelIsCheck
       ,Account = @Account
    WHERE DiscountCheckId = @DiscountCheckId;
    SET @IdCreated = 0;
  END;
END;
GO