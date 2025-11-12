SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/26-08-2024 Allow create cashiers with the same number and email, than another user client
-- =============================================
-- Author:      JF
-- Create date: 21/07/2024 6:44 p. m.
-- Database:    copiaDevtest
-- Description: ask 5956 Registrar fecha y persona que editar el salario a algún cajero
-- =============================================
-- =============================================
-- Author:      JF
-- Create date: 31/07/2024 4:35 p. m.
-- Database:    devCopySecure
-- Description: task 5980 Validación sick hours accumulate
-- =============================================
-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_CreateCashier] (@UserId INT = NULL,
@Name VARCHAR(80),
@Telephone VARCHAR(20),
@Telephone2 VARCHAR(20) = NULL,
@ZipCode VARCHAR(10),
@State VARCHAR(20),
@City VARCHAR(20),
@County VARCHAR(20) = NULL,
@Address VARCHAR(70) = NULL,
@Email VARCHAR(50),
@Pass VARCHAR(50) = NULL,
@IsActive VARCHAR(50) = NULL,
@ViewReports BIT = NULL,
@AllowManipulateFiles BIT,
@StartDate DATETIME = NULL,
@CycleDateVacation DATETIME = NULL,
@SocialSecurity VARCHAR(9) = NULL,
@PaymentType VARCHAR(10) = NULL,
@USD DECIMAL(18, 2) = NULL,
@Birthday DATETIME = NULL,
@CashFund DECIMAL(18, 2),
@AccessProperties BIT,
@CreationDate DATETIME,
@CreatedBy INT,
@CashFundAgencyId INT = NULL,
@IsManager BIT,
@IsAdmin BIT,
@SecurityLevelId INT = NULL,
@TelIsCheck BIT = NULL,
@EmailIsCheck BIT = NULL,
@ComplianceRol INT = NULL,
@IsComissions BIT,
@ValidComissions DATE = NULL,
@LastPasswordChangeDate DATETIME = NULL,
@HoursPromedial DECIMAL(18, 2) = NULL,
@VacationHoursAccumulated DECIMAL(18, 2) = NULL,
@NewCashierOffice INT = NULL,
@NewCashierReview INT = NULL,
@IsSocialSecurityInternal BIT = NULL,
@IsW4Internal BIT = NULL,
@IsConfidentialityInternal BIT = NULL,
@IsAddressProofInternal BIT = NULL,
@IsDirectDepositInternal BIT = NULL,
@IsBiometricInformationInternal BIT = NULL,
@IsIdentificationInternal BIT = NULL,
@IsEmploymentApplicationInternal BIT = NULL,
@UserCreatedOn DATETIME = NULL
, @UserCreatedBy INT = NULL
, @UserLastUpdatedOn DATETIME = NULL
, @UserLastUpdatedBy INT = NULL
, @LastUpdatedStartingDate DATETIME = NULL
, @LastUpdatedStartingDateBy INT = NULL
, @LastUpdatedsalaryOn DATETIME = NULL
, @LastUpdatedSalaryBy INT = NULL
, @LastUpdatedSickHrsOn DATETIME = NULL
, @LastUpdatedSickHrsBy INT = NULL)
AS
BEGIN

  --Consultamos el id del compliance officer por medio del codigo
  DECLARE @ComplianceOfficerId INT;
  SELECT
    @ComplianceOfficerId = (SELECT
        RC.RolComplianceId
      FROM RolCompliance RC
      WHERE RC.Code = 'C02')

  --Consultamos el id del Independent review por medio del codigo
  DECLARE @IndependentReviewId INT;
  SELECT
    @IndependentReviewId = (SELECT
        RC.RolComplianceId
      FROM RolCompliance RC
      WHERE RC.Code = 'C03')


  --Commented task 5441
  --  DECLARE @oldCashFund DECIMAL(18, 2);
  --  SET @oldCashFund = ISNULL((SELECT TOP 1
  --      CashFund
  --    FROM Cashiers
  --    WHERE UserId = @UserId)
  --  , 0);
  DECLARE @cashierId INT;
  SET @cashierId = (SELECT TOP 1
      CashierId
    FROM Cashiers
    WHERE UserId = @UserId);
  IF (@ViewReports IS NULL)
  BEGIN
    SET @ViewReports = 1;
  END;

  IF (NOT EXISTS (SELECT
        *
      FROM ZipCodes
      WHERE ZipCode = @ZipCode)
    )
  BEGIN
    INSERT INTO [dbo].[ZipCodes] ([ZipCode],
    [City],
    [State],
    [County])
      VALUES (@ZipCode, @City, @State, @County);
  END;

  IF (EXISTS (SELECT
        Cashiers.CashierId
      FROM Cashiers
      INNER JOIN RolCompliance r
        ON r.RolComplianceId = ComplianceRol
      WHERE r.Code = 'C02'
      AND (UserId != @UserId
      OR @UserId IS NULL)
      AND (@ComplianceRol = @ComplianceOfficerId)
      AND Cashiers.IsActive = 1)

    )
  BEGIN
    SELECT
      -2; --Error Already exists compliance officer
  END;

  IF (EXISTS (SELECT
        Cashiers.UserId
      FROM Cashiers
      INNER JOIN RolCompliance r
        ON r.RolComplianceId = ComplianceRol
      WHERE r.Code = 'C03'
      AND (Cashiers.UserId != @UserId
      OR @UserId IS NULL)
      AND (@ComplianceRol = @IndependentReviewId)
      AND Cashiers.IsActive = 1)

    )
  BEGIN
    SELECT
      -5; --Error Already exists compliance interview person
  END;

  DECLARE @VacationHoursAccumulatedSaved DECIMAL(18, 2)
  SET @VacationHoursAccumulatedSaved = (SELECT
      u.VacationHoursAccumulated
    FROM Users u
    WHERE UserId = @UserId);


  IF (@VacationHoursAccumulated != @VacationHoursAccumulatedSaved)
  BEGIN
    IF (EXISTS (SELECT TOP 1
          CAST(1 AS BIT)
        FROM EmployeeVacations ev
        WHERE ev.UserId = @UserId)

      )
    BEGIN
      SELECT
        -8; --Error Already exists  hours taken the vacations 
    END;

  END







  IF (@UserId IS NOT NULL
    AND CAST(@IsActive AS BIT) = 0
    AND ((SELECT
        [dbo].FN_GeneratependingMissing(NULL, NULL, @CashierId, NULL))
    > 0)
    )
  BEGIN
    SELECT
      -6; --Error Already has pending missing
  END;

  ELSE
  IF (@UserId IS NULL)
  BEGIN
    IF (EXISTS (SELECT
          1
        FROM Users
        INNER JOIN Cashiers c
          ON Users.UserId = c.UserId
        WHERE [User] = @Email)
      )
    BEGIN
      SELECT
        -1;
    END;
    ELSE
    IF (EXISTS (SELECT
          1
        FROM Users
        INNER JOIN Cashiers c
          ON Users.UserId = c.UserId
        WHERE SocialSecurity = @SocialSecurity)
      )
    BEGIN
      SELECT
        -3;
    END;
    ELSE
    IF (EXISTS (SELECT
          1
        FROM Users
        INNER JOIN Cashiers c
          ON Users.UserId = c.UserId
        WHERE Telephone = @Telephone)
      )
    BEGIN
      SELECT
        -4;
    END;
    ELSE
    BEGIN
      INSERT INTO [dbo].[Users] ([Name],
      [Telephone],
      [Telephone2],
      [ZipCode],
      [Address],
      [User],
      [Pass],
      [UserType],
      [Lenguage],
      [StartingDate],
      [SocialSecurity],
      [PaymentType],
      [USD],
      [BirthDay],
      TelIsCheck,
      EmailIsCheck,
      LastPasswordChangeDate,
      HoursPromedial,
      VacationHoursAccumulated,
      UserCreatedOn
      , UserCreatedBy
      , UserLastUpdatedOn
      , UserLastUpdatedBy
      , [LastUpdatedStartingDate ]
      , LastUpdatedStartingDateBy
      , LastUpdatedsalaryOn
      , LastUpdatedSalaryBy
      , LastUpdatedSickHrsOn
      , LastUpdatedSickHrsBy)
        VALUES (@Name, @Telephone, @Telephone2, @ZipCode, @Address, @Email, @Pass, 2, 1, @StartDate, @SocialSecurity, @PaymentType, @USD, @Birthday, @TelIsCheck, @EmailIsCheck, @LastPasswordChangeDate, @HoursPromedial, @VacationHoursAccumulated, @UserCreatedOn, @UserCreatedBy, @UserLastUpdatedOn, @UserLastUpdatedBy, @LastUpdatedStartingDate, @LastUpdatedStartingDateBy, @LastUpdatedsalaryOn, @LastUpdatedSalaryBy, @LastUpdatedSickHrsOn, @LastUpdatedSickHrsBy);
      DECLARE @userIdTran INT;
      SET @userIdTran = @@IDENTITY;
      INSERT INTO [dbo].[Cashiers] ([UserId],
      ViewReports,
      AllowManipulateFiles,
      CashFund,
      AccessProperties,
      [IsManager],
      IsAdmin,
      SecurityLevelId,
      ComplianceRol,
      IsComissions,
      ValidComissions,
      CycleDateVacation,
      IsSocialSecurityInternal,
      IsW4Internal,
      IsConfidentialityInternal,
      IsAddressProofInternal,
      IsDirectDepositInternal,
      IsBiometricInformationInternal,
      IsIdentificationInternal,
      IsEmploymentApplicationInternal)
        VALUES (@userIdTran, @ViewReports, @AllowManipulateFiles, @CashFund, @AccessProperties, @IsManager, @IsAdmin, @SecurityLevelId, @ComplianceRol, @IsComissions, @ValidComissions, @CycleDateVacation, @IsSocialSecurityInternal, @IsW4Internal, @IsConfidentialityInternal, @IsAddressProofInternal, @IsDirectDepositInternal, @IsBiometricInformationInternal, @IsIdentificationInternal, @IsEmploymentApplicationInternal);
      SET @cashierId = @@IDENTITY;
      --Commented task 5441
      --      IF (@CashFund > 0)
      --      BEGIN
      --        INSERT INTO [dbo].[CashFundModifications] ([CashierId],
      --        [OldCashFund],
      --        [NewCashFund],
      --        [CreationDate],
      --        [CreatedBy],
      --        [AgencyId],
      --        [FirstCashFund])
      --          VALUES (@cashierId, 0, @CashFund, @CreationDate, @CreatedBy, @CashFundAgencyId, CAST(1 AS BIT));
      --      END;
      SELECT
        @userIdTran;
    END;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].[Users]
    SET [Name] = @Name
       ,[Telephone] = @Telephone
       ,[Telephone2] = @Telephone2
       ,[ZipCode] = @ZipCode
       ,[Address] = @Address
       ,[User] = @Email
       ,[StartingDate] = @StartDate
       ,[SocialSecurity] = @SocialSecurity
       ,[PaymentType] = @PaymentType
       ,[USD] = @USD
       ,[BirthDay] = @Birthday
       ,TelIsCheck = @TelIsCheck
       ,EmailIsCheck = @EmailIsCheck
       ,LastPasswordChangeDate = @LastPasswordChangeDate
       ,HoursPromedial = @HoursPromedial
       ,VacationHoursAccumulated = @VacationHoursAccumulated
        --       UserCreatedOn = @UserCreatedOn
        -- ,UserCreatedBy = @UserCreatedBy
       ,UserLastUpdatedOn = @UserLastUpdatedOn
       ,UserLastUpdatedBy = @UserLastUpdatedBy
       ,LastUpdatedStartingDate = @LastUpdatedStartingDate
       ,LastUpdatedStartingDateBy = @LastUpdatedStartingDateBy
       ,LastUpdatedsalaryOn = @LastUpdatedsalaryOn
       ,LastUpdatedSalaryBy = @LastUpdatedSalaryBy
       ,LastUpdatedSickHrsOn = @LastUpdatedSickHrsOn
       ,LastUpdatedSickHrsBy = @LastUpdatedSickHrsBy
    WHERE UserId = @UserId;
    UPDATE [dbo].[Cashiers]
    SET [IsActive] = @IsActive
       ,ViewReports = @ViewReports
       ,AllowManipulateFiles = @AllowManipulateFiles
       ,[CashFund] = @CashFund
       ,[AccessProperties] = @AccessProperties
       ,[IsManager] = @IsManager
       ,IsAdmin = @IsAdmin
       ,SecurityLevelId = @SecurityLevelId
       ,ComplianceRol = @ComplianceRol
       ,IsComissions = @IsComissions
       ,ValidComissions = @ValidComissions
        --       ,CycleDateVacation = @CycleDateVacation
       ,IsSocialSecurityInternal = @IsSocialSecurityInternal
       ,IsW4Internal = @IsW4Internal
       ,IsConfidentialityInternal = @IsConfidentialityInternal
       ,IsAddressProofInternal = @IsAddressProofInternal
       ,IsDirectDepositInternal = @IsDirectDepositInternal
       ,IsBiometricInformationInternal = @IsBiometricInformationInternal
       ,IsIdentificationInternal = @IsIdentificationInternal
       ,IsEmploymentApplicationInternal = @IsEmploymentApplicationInternal
    WHERE UserId = @UserId;

    IF (@NewCashierOffice IS NOT NULL)
    BEGIN

      DECLARE @SetNewOfficerCashier INT;
      SET @SetNewOfficerCashier = (SELECT
          rc.RolComplianceId
        FROM RolCompliance rc
        WHERE rc.Code = 'C02')
      UPDATE [dbo].[Cashiers]
      SET ComplianceRol = @SetNewOfficerCashier
      WHERE UserId = @NewCashierOffice;
    END

    IF (@NewCashierReview IS NOT NULL)
    BEGIN

      DECLARE @SetNewCashierReview INT;
      SET @SetNewCashierReview = (SELECT
          rc.RolComplianceId
        FROM RolCompliance rc
        WHERE rc.Code = 'C03')
      UPDATE [dbo].[Cashiers]
      SET ComplianceRol = @SetNewCashierReview
      WHERE UserId = @NewCashierReview;
    END

    --Commented task 5441
    --    IF (@oldCashFund <> @CashFund)
    --    BEGIN
    --      DECLARE @first BIT;
    --      SET @first = 0;
    --      IF (NOT EXISTS (SELECT
    --            *
    --          FROM CashFundModifications
    --          WHERE CashierId = @cashierId)
    --        )
    --      BEGIN
    --        SET @first = 1;
    --      END;
    --      INSERT INTO [dbo].[CashFundModifications] ([CashierId],
    --      [OldCashFund],
    --      [NewCashFund],
    --      [CreationDate],
    --      [CreatedBy],
    --      [AgencyId],
    --      [FirstCashFund])
    --        VALUES (@cashierId, @oldCashFund, @CashFund, @CreationDate, @CreatedBy, @CashFundAgencyId, @first);
    --    END;
    --    ELSE
    --    BEGIN
    --      IF (@CashFund > 0
    --        AND NOT EXISTS (SELECT
    --            *
    --          FROM CashFundModifications
    --          WHERE CashierId = @cashierId)
    --        )
    --      BEGIN
    --        INSERT INTO [dbo].[CashFundModifications] ([CashierId],
    --        [OldCashFund],
    --        [NewCashFund],
    --        [CreationDate],
    --        [CreatedBy],
    --        [AgencyId],
    --        [FirstCashFund])
    --          VALUES (@cashierId, 0, @CashFund, @CreationDate, @CreatedBy, @CashFundAgencyId, CAST(1 AS BIT));
    --      END;
    --    END;
    SELECT
      @UserId;
  END;
END;


GO