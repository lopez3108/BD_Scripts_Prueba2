SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveTitle]
 (
    @TitleId INT = NULL,
    @ProcessStatusId INT = NULL,
    @ProcessStatusCode VARCHAR(10) = NULL,
    @ProcessTypeId INT = NULL,
    @PlateNumber VARCHAR(20) = NULL,
    @PlateTypeId INT = NULL,
    @ClientName VARCHAR(70) = NULL,
    @Telephone VARCHAR(10),
    @Email VARCHAR(50) = NULL,
    @DeliveryTypeId INT = NULL,
    @Fee1 DECIMAL(18, 2),
    @Financial DECIMAL(18, 2) = NULL,
    @FinancingId INT = NULL,
    @Usd DECIMAL(18, 2),
    @CreatedBy INT,
    @CreationDate DATETIME,
    @IdCreated INT OUTPUT,
    @PackageNumber VARCHAR(15) = NULL,
    @DeliveryBy VARCHAR(50) = NULL,
    @Dunbar DATETIME = NULL,
    @DeliveredPackageDate DATETIME = NULL,
    @UpdatedBy INT = NULL,
    @AgencyId INT = NULL,
    @ProcessAuto BIT = NULL,
    @FeeILDOR DECIMAL(18, 2) = NULL,
    @MOILDOR DECIMAL(18, 2) = NULL,
    @FeeILSOS DECIMAL(18, 2) = NULL,
    @MOLSOS DECIMAL(18, 2) = NULL,
    @FeeOther DECIMAL(18, 2) = NULL,
    @MOOther DECIMAL(18, 2) = NULL,
    @SellerId INT = NULL,
    @BuyingPrice DECIMAL(18, 2) = NULL,
    @RunnerService DECIMAL(18, 2) = NULL,
    @PlateTypePersonalizedId INT = NULL,
    @PlateTypeOtherTruckId INT = NULL,
    @PlateTypeTrailerId INT = NULL,
    @PlateTypePersonalizedFee DECIMAL(18, 2) = NULL,
    @CardPayment BIT,
    @CardPaymentFee DECIMAL(18, 2) = NULL,
    @FileIdName VARCHAR(MAX) = NULL,
    @FileIdName2 VARCHAR(MAX) = NULL,
    @FeeEls DECIMAL(18, 2),
    @FileIdNameTitle VARCHAR(MAX) = NULL,
    @FileIdNameElsCopy VARCHAR(MAX) = NULL,
    @FileIdNameTitleM VARCHAR(MAX) = NULL,
    @FileIdNameMoIlsos VARCHAR(MAX) = NULL,
    @FileIdNameMo VARCHAR(MAX) = NULL,
    @FileIdNameRut VARCHAR(MAX) = NULL,
    @FileIdNameVehicle VARCHAR(MAX) = NULL,
    @FileIdNameAttorney VARCHAR(MAX) = NULL,
    @TelIsCheck BIT = NULL,
    @FileIdNameTitleBack VARCHAR(MAX) = NULL,
    @FileIdNameTitleMBack VARCHAR(MAX) = NULL,
    @FileIdNameProofAddress VARCHAR(1000) = NULL,
    @ValidatedBy INT = NULL,
    @ValidatedOn DATETIME = NULL,
    @UpdatedOn DATETIME = NULL,
    @PlateDesignId INT = NULL,
    @DatePendingState DATETIME = NULL,
    @DatePending DATETIME = NULL,
    @DateReceived DATETIME = NULL,
    @DateCompleted DATETIME = NULL,
    @DatePendingStateBy INT = NULL,
    @DatePendingBy INT = NULL,
    @DateReceivedBy INT = NULL,
    @DateCompletedBy INT = NULL,
    @Cash DECIMAL(18, 2) = NULL,
    @HasId2 BIT = NULL,
    @HasProofAddress BIT = NULL,
    @IdExpirationDate DATETIME = NULL,
    @ChooseMsg BIT = NULL,
    @VinNumber VARCHAR(50) = NULL,
    @CashierCommission DECIMAL (18, 2) = NULL
   
 )

AS
BEGIN
  --IF(@PlateDesignId IS NULL)
  --    BEGIN
  --        SET @PlateDesignId =
  --        (
  --            SELECT TOP 1 PlateDesignId
  --            FROM PlateDesign
  --            WHERE Code = 'C01'
  --        );
  --    END;
  --DECLARE @plateDesignCode VARCHAR(5);
  --SET @plateDesignCode =
  --(
  --    SELECT TOP 1 Code
  --    FROM PlateDesign
  --    WHERE PlateDesignId = @PlateDesignId
  --);
  --IF(@plateDesignCode = 'C01')
  --    BEGIN
  --        SET @PlateTypePersonalizedId = NULL;
  --    END;
  IF (@ProcessStatusCode IS NOT NULL)
  BEGIN
    SET @ProcessStatusId = (SELECT
        ProcessStatusId
      FROM ProcessStatus
      WHERE Code = @ProcessStatusCode);
  END;
  IF (@TitleId IS NULL)
  BEGIN
    INSERT INTO [dbo].[Titles] (ProcessTypeId,
    PlateNumber,
    PlateTypeId,
    Name,
    Telephone,
    Email,
    DeliveryTypeId,
    Financial,
    USD,
    Fee1,
    CreatedBy,
    UpdatedBy,
    CreationDate,
    ProcessStatusId,
    PackageNumber,
    DeliveryBy,
    Dunbar,
    AgencyId,
    ProcessAuto,
    FeeILDOR,
    MOILDOR,
    FeeILSOS,
    MOLSOS,
    FeeOther,
    MOOther,
    RunnerService,
    PlateTypePersonalizedId,
    PlateTypeOtherTruckId,
    PlateTypeTrailerId,
    PlateTypePersonalizedFee,
    FinancingId,
    CardPayment,
    CardPaymentFee,
    FileIdName,
    FileIdName2,
    FeeEls,
    SellerId,
    BuyingPrice,
    FileIdNameTitle,
    FileIdNameTitleBack,
    FileIdNameElsCopy,
    FileIdNameTitleM,
    FileIdNameTitleMBack,
    FileIdNameMo,
    FileIdNameRut,
    FileIdNameVehicle,
    FileIdNameAttorney,
    TelIsCheck,
    FileIdNameMoIlsos,
    FileIdNameProofAddress,
    UpdatedOn,
    PlateDesignId,
    DatePendingState,
    DatePending,
    DateReceived,
    DatePendingStateBy,
    DatePendingBy,
    DateReceivedBy,
    DateCompletedBy,
    DateCompleted,
    Cash,
    HasId2,
    HasProofAddress,
    IdExpirationDate,
    ChooseMsg, 
    VinNumber,
    CashierCommission)
      VALUES (@ProcessTypeId, @PlateNumber, @PlateTypeId, @ClientName, @Telephone, @Email, @DeliveryTypeId, @Financial, @Usd, @Fee1, @CreatedBy, @UpdatedBy, @CreationDate, @ProcessStatusId, @PackageNumber, @DeliveryBy, @Dunbar, @AgencyId, @ProcessAuto, @FeeILDOR, @MOILDOR, @FeeILSOS, @MOLSOS, @FeeOther, @MOOther, @RunnerService, @PlateTypePersonalizedId, @PlateTypeOtherTruckId, @PlateTypeTrailerId, @PlateTypePersonalizedFee, @FinancingId, @CardPayment, @CardPaymentFee, @FileIdName, @FileIdName2, @FeeEls, @SellerId, @BuyingPrice, @FileIdNameTitle, @FileIdNameTitleBack, @FileIdNameElsCopy, @FileIdNameTitleM, @FileIdNameTitleMBack, @FileIdNameMo, @FileIdNameRut, @FileIdNameVehicle, @FileIdNameAttorney, @TelIsCheck, @FileIdNameMoIlsos, @FileIdNameProofAddress, @UpdatedOn, @PlateDesignId, @DatePendingState, @DatePending, @DateReceived, @DatePendingStateBy, @DatePendingBy, @DateReceivedBy, @DateCompletedBy, @DateCompleted, @Cash, @HasId2, @HasProofAddress, @IdExpirationDate, @ChooseMsg, @VinNumber,@CashierCommission);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].[Titles]
    SET ProcessTypeId = @ProcessTypeId
       ,PlateNumber = @PlateNumber
       ,PlateTypeId = @PlateTypeId
       ,Name = @ClientName
       ,Telephone = @Telephone
       ,Email = @Email
       ,DeliveryTypeId = @DeliveryTypeId
       ,Financial = @Financial
       ,USD = @Usd
       ,Fee1 = @Fee1
       ,
        --CreatedBy = @CreatedBy,
        --CreationDate = @CreationDate,
        ProcessStatusId = @ProcessStatusId
       ,PackageNumber = @PackageNumber
       ,DeliveryBy = @DeliveryBy
       ,Dunbar = @Dunbar
       ,DeliveredPackageDate = @DeliveredPackageDate
       ,UpdatedBy = @UpdatedBy
       ,FeeILDOR = @FeeILDOR
       ,MOILDOR = @MOILDOR
       ,FeeILSOS = @FeeILSOS
       ,MOLSOS = @MOLSOS
       ,FeeOther = @FeeOther
       ,MOOther = @MOOther
       ,RunnerService = @RunnerService
       ,PlateTypePersonalizedId = @PlateTypePersonalizedId
       ,PlateTypePersonalizedFee = @PlateTypePersonalizedFee
       ,FinancingId = @FinancingId
       ,CardPayment = @CardPayment
       ,CardPaymentFee = @CardPaymentFee
       ,FileIdName = @FileIdName
       ,FileIdName2 = @FileIdName2
       ,FeeEls = @FeeEls
       ,SellerId = @SellerId
       ,BuyingPrice = @BuyingPrice
       ,FileIdNameTitle = @FileIdNameTitle
       ,FileIdNameTitleBack = @FileIdNameTitleBack
       ,FileIdNameElsCopy = @FileIdNameElsCopy
       ,FileIdNameTitleM = @FileIdNameTitleM
       ,FileIdNameTitleMBack = @FileIdNameTitleMBack
       ,FileIdNameMo = @FileIdNameMo
       ,FileIdNameRut = @FileIdNameRut
       ,FileIdNameVehicle = @FileIdNameVehicle
       ,FileIdNameAttorney = @FileIdNameAttorney
       ,TelIsCheck = @TelIsCheck
       ,FileIdNameMoIlsos = @FileIdNameMoIlsos
       ,FileIdNameProofAddress = @FileIdNameProofAddress
       ,ValidatedBy = @ValidatedBy
       ,ValidatedOn = @ValidatedOn
       ,UpdatedOn = @UpdatedOn
       ,PlateTypeOtherTruckId = @PlateTypeOtherTruckId
       ,PlateTypeTrailerId = @PlateTypeTrailerId
       ,PlateDesignId = @PlateDesignId
       ,DatePendingState = @DatePendingState
       ,DatePending = @DatePending
       ,DateReceived = @DateReceived
       ,DatePendingStateBy = @DatePendingStateBy
       ,DatePendingBy = @DatePendingBy
       ,DateReceivedBy = @DateReceivedBy
       ,DateCompletedBy = @DateCompletedBy
       ,DateCompleted = @DateCompleted
       ,Cash = @Cash
       ,HasId2 = @HasId2
       ,HasProofAddress = @HasProofAddress
       ,IdExpirationDate = @IdExpirationDate
       ,ChooseMsg = @ChooseMsg
       ,VinNumber = @VinNumber
    WHERE TitleId = @TitleId;
    SET @IdCreated = @TitleId;
  END;
END;



GO