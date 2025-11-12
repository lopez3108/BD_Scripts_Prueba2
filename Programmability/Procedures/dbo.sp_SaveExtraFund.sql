SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveExtraFund]
(
                 @ExtraFundId int = NULL, @CreationDate datetime = NULL, @Usd decimal(18, 2), @Reason varchar(50) = NULL, @CreatedBy int = NULL, @AssignedTo int = NULL, @LastUpdated datetime = NULL, @LastUpdatedBy int = NULL, @AgencyId int, @CashAdmin bit, @IsCashier bit
)
AS
BEGIN

  IF NOT EXISTS (SELECT 1
FROM ExtraFund
WHERE ExtraFundId = @ExtraFundId)
  BEGIN
    INSERT INTO [dbo].ExtraFund (CreationDate,
    Usd,
    Reason,
    CreatedBy,
    LastUpdated,
    LastUpdatedBy,
    AgencyId,
    AssignedTo,
    CashAdmin,
    IsCashier)
    VALUES(@CreationDate, @Usd, @Reason, @CreatedBy, @LastUpdated, @LastUpdatedBy, @AgencyId, @AssignedTo, @CashAdmin, @IsCashier);
  END;
  ELSE
  BEGIN
    UPDATE [dbo].ExtraFund
      SET
      --CreationDate = @CreationDate,
      Usd = @Usd
      ,
      --CreatedBy = @CreatedBy,
      LastUpdated = @LastUpdated
      , LastUpdatedBy = @LastUpdatedBy
      , AssignedTo = @AssignedTo
      , CashAdmin = @CashAdmin
      , IsCashier = @IsCashier
      , Reason =  @Reason 
    WHERE ExtraFundId = @ExtraFundId;
  END;

END;

GO