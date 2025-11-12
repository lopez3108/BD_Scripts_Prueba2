SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by jt/23-09-2025 task 6753 Allow edit money distribution
CREATE PROCEDURE [dbo].[sp_SaveMoneyDistribution] (@MoneyDistributionId INT = NULL,
@BankAccountId INT = NULL,
@IsDefault BIT,
@MoneyTransferxAgencyNumbersId INT = NULL,
@CashierId INT,
@Active BIT)
AS
BEGIN
  IF (@MoneyDistributionId IS NULL)
  BEGIN

    INSERT INTO [dbo].MoneyDistribution (IsDefault,
    BankAccountId,
    MoneyTransferxAgencyNumbersId,
    CashierId)
      VALUES (@IsDefault, @BankAccountId, @MoneyTransferxAgencyNumbersId, @CashierId);

    SELECT
      @@IDENTITY

  END;
  ELSE
  BEGIN
    UPDATE [dbo].MoneyDistribution
    SET IsDefault = @IsDefault
       ,BankAccountId = @BankAccountId
       ,MoneyTransferxAgencyNumbersId = @MoneyTransferxAgencyNumbersId
    --       ,Active = @Active
    WHERE MoneyDistributionId = @MoneyDistributionId;

    SELECT
      @MoneyDistributionId
  END;
END;

GO