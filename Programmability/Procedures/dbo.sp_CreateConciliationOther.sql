SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/23-06-2025 TASK 6617 Permitir completar varios expenses bank
--Last update by JT/22-07-2025 TASK 6617 Permitir editar expenses bank en pending
-- 2025-07-30 DJ/6676 Permitir editar expenses bank en status pending

CREATE PROCEDURE [dbo].[sp_CreateConciliationOther] @ConciliationOtherTypeId INT,
@AgencyId INT = NULL,
@BankAccountId INT,
@CreatedBy INT,
@Date DATETIME,
@IsCredit BIT,
@CreationDate DATETIME,
@Usd DECIMAL(18, 2),
@CapitalUsd DECIMAL(18, 2) = NULL,
@InterestUsd DECIMAL(18, 2) = NULL,
@Description VARCHAR(60) = NULL,
@ConciliationOtherId INT = NULL,
@CodeStatus VARCHAR(60) = NULL,
@CompletedBy INT = NULL,
@CompletedOn DATETIME = NULL,
@LastUpdatedBy INT = NULL,
@LastUpdatedOn DATETIME = NULL

AS
BEGIN
  DECLARE @CurrentStatus VARCHAR(8);

  SET @CurrentStatus = (SELECT TOP 1 
      ebs.Code
    FROM dbo.ExpenseBankStatus ebs INNER JOIN ConciliationOthers CLO ON ebs.ExpenseBankStatusId = CLO.ExpenseBankStatusId
    WHERE clo.ConciliationOtherId = @ConciliationOtherId)
  IF (@CurrentStatus = 'C02')
  BEGIN
    SELECT
      -1;
  END
  ELSE
  BEGIN

    IF (@ConciliationOtherId IS NULL)
    BEGIN

      INSERT INTO [dbo].[ConciliationOthers] ([ConciliationOtherTypeId]
      , [AgencyId]
      , [BankAccountId]
      , [Date]
      , [IsCredit]
      , [Usd]
      , [CapitalUsd]
      , [InterestUsd]
      , [CreatedBy]
      , [CreationDate]
      , [Description]
      , [ExpenseBankStatusId]
      , LastUpdatedBy
      , LastUpdatedOn)
        VALUES (@ConciliationOtherTypeId, @AgencyId, @BankAccountId, @Date, @IsCredit, @Usd, @CapitalUsd, @InterestUsd, @CreatedBy, @CreationDate, @Description, (SELECT ebs.ExpenseBankStatusId FROM dbo.ExpenseBankStatus ebs WHERE ebs.Code = @CodeStatus), @LastUpdatedBy, @LastUpdatedOn)

      SELECT
        @@IDENTITY

    END
    ELSE
    BEGIN

      UPDATE [dbo].[ConciliationOthers]
      SET ExpenseBankStatusId = (SELECT
              ebs.ExpenseBankStatusId
            FROM dbo.ExpenseBankStatus ebs
            WHERE ebs.Code = @CodeStatus)
         ,[ConciliationOtherTypeId] = @ConciliationOtherTypeId
         ,Description = @Description
         ,AgencyId = @AgencyId
         ,[BankAccountId] = @BankAccountId
         ,[Date] = @Date
         ,[IsCredit] = @IsCredit
         ,[Usd] = @Usd
         ,[CapitalUsd] = @CapitalUsd
         ,[InterestUsd] = @InterestUsd
         ,CompletedBy = @CompletedBy
         ,CompletedOn = @CompletedOn
         ,LastUpdatedBy = @LastUpdatedBy
         ,LastUpdatedOn = @LastUpdatedOn
      WHERE ConciliationOtherId = @ConciliationOtherId

      SELECT
        @ConciliationOtherId


    END
  END
END




GO