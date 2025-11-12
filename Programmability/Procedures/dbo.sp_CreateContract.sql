SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/03-09-2025 task 6722 Contracts deben poder quedar en status PENDING cuando se crean

CREATE PROCEDURE [dbo].[sp_CreateContract] (@ContractId INT = NULL,
@ApartmentsId INT,
@StartDate DATETIME,
@EndDate DATETIME,
@RentValue DECIMAL(18, 2),
@DownPayment DECIMAL(18, 2),
@Note VARCHAR(500) = NULL,
@LengthId INT,
@CreationDate DATETIME,
@CreatedBy INT,
@FinancingDeposit BIT,
@AgencyId INT,
@Adults INT,
@Children INT = NULL,
@Pets BIT,
@PetsReason VARCHAR(200) = NULL,
@ContractFileName VARCHAR(MAX) = NULL,
@Dayslate INT = NULL,
@MonthlyPaymentDate INT = NULL,
@FeeDue DECIMAL(18, 2) = NULL,
@AddTerms BIT = NULL,
@DepositBankAccountId INT = NULL,
@MoveInFee DECIMAL(18, 2) = NULL,
@TextConsent BIT,
@DepositRefundFee DECIMAL(18, 2) = 0,
@IsPendingInformation BIT)
AS
BEGIN
  IF (@ContractId IS NULL)
  BEGIN
    DECLARE @ContractStatusId INT;
    SET @ContractStatusId = (SELECT TOP 1
        ContractStatusId
      FROM ContractStatus
      WHERE Code = 'C01'); -- Activo


    INSERT INTO [dbo].[Contract] ([ApartmentId],
    [StartDate],
    [EndDate],
    [RentValue],
    [DownPayment],
    [LengthId],
    [Status],
    [CreationDate],
    [CreatedBy],
    [FinancingDeposit],
    [AgencyId],
    Adults,
    Children,
    Pets,
    PetsReason,
    ContractFileName,
    Dayslate,
    MonthlyPaymentDate,
    FeeDue,
    FeeNfs,
    DaysMaxiAband,
    AddTerms,
    DepositBankAccountId,
    MoveInFee,
    TextConsent,
    DepositRefundFee,
    IsPendingInformation)
      VALUES (@ApartmentsId, @StartDate, @EndDate, @RentValue, @DownPayment, @LengthId, @ContractStatusId, @CreationDate, @CreatedBy, @FinancingDeposit, @AgencyId, @Adults, @Children, @Pets, @PetsReason, @ContractFileName, (SELECT TOP 1 pc.Dayslate FROM dbo.PropertiesConfiguration pc), (SELECT TOP 1 pc.MonthlyPaymentDate FROM dbo.PropertiesConfiguration pc), @FeeDue, (SELECT TOP 1 pc.FeeNfs FROM dbo.PropertiesConfiguration pc), (SELECT TOP 1 pc.DaysMaxiAband FROM dbo.PropertiesConfiguration pc), @AddTerms, @DepositBankAccountId, @MoveInFee, @TextConsent, @DepositRefundFee,@IsPendingInformation);
    DECLARE @contractNewId INT;
    SET @contractNewId = @@IDENTITY;
    IF (@Note IS NOT NULL)
    BEGIN
      INSERT INTO [dbo].[ContractNotes] ([ContractId],
      [Note],
      [CreationDate],
      [CreatedBy])
        VALUES (@contractNewId, @Note, @CreationDate, @CreatedBy);
    END;
    SELECT
      @contractNewId;
  --INSERT INTO [dbo].[PropertyControlsXProperty]
  --       SELECT pr.[PropertyControlId], 
  --              NULL, 
  --              @ApartmentsId, 
  --              @CreationDate, 
  --              NULL, 
  --              0, 
  --              @CreationDate, 
  --              @CreatedBy, 
  --              1, 
  --              NULL, 
  --              NULL, 
  --              NULL
  --       FROM [dbo].[PropertyControls] pr;

  END;
  ELSE
  BEGIN
    UPDATE [Contract]
    SET LastUpdatedOn = @CreationDate
       ,LastUpdatedBy = @CreatedBy
       ,Adults = @Adults
       ,Children = @Children
       ,Pets = @Pets
       ,PetsReason = @PetsReason
       ,ContractFileName = @ContractFileName
       ,AddTerms = @AddTerms
       ,[StartDate] = @StartDate
       ,[EndDate] = @EndDate
       ,IsPendingInformation = @IsPendingInformation
       ,DepositBankAccountId = @DepositBankAccountId
    WHERE ContractId = @ContractId;
    SELECT
      @ContractId;
  END;
END;


GO