SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveTRP] (@TRPId INT = NULL,
@PermitTypeId INT = NULL,
@PermitNumber VARCHAR(20) = NULL,
@ClientName VARCHAR(70) = NULL,
@Telephone VARCHAR(10),
@Email VARCHAR(50) = NULL,
@Usd DECIMAL(18, 2),
@Fee1 DECIMAL(18, 2),
@Cash DECIMAL(18, 2) = NULL,
@CreatedBy INT,
@CreatedOn DATETIME,
@AgencyId INT = NULL,
@IdCreated INT OUTPUT,
@CardPayment BIT,
@CardPaymentFee DECIMAL(18, 2) = NULL,
@TrpFee DECIMAL(18, 2) = NULL,
@LaminationFee DECIMAL(18, 2) = NULL,
@FileIdName VARCHAR(1000) = NULL,
@FileIdName2 VARCHAR(1000) = NULL,
@UpdatedBy INT = NULL,
@UpdatedOn DATETIME = NULL,
@FileIdNamePermit VARCHAR(1000) = NULL,
@FileIdNameTrpT VARCHAR(1000) = NULL,
@FileIdNameTrpTBack VARCHAR(1000) = NULL,
@FileIdNameProofAddress VARCHAR(1000) = NULL,
@TelIsCheck BIT = NULL,
@VinPertmitTrpId INT,
@VinNumber VARCHAR(17),
@HasId2 BIT = NULL,
@HasProofAddress BIT = NULL,
@IdExpirationDate DATETIME = NULL,
@FeeElsSale DECIMAL(18, 2) = NULL,
@FeeElsTrpSale DECIMAL(18, 2) = NULL,
@CashierCommission DECIMAL (18, 2) = NULL
)
AS
BEGIN
  IF (@TRPId IS NULL)
  BEGIN
    INSERT INTO [dbo].[TRP] (PermitTypeId,
    PermitNumber,
    ClientName,
    Telephone,
    Email,
    Usd,
    Fee1,
    Cash,
    CreatedOn,
    CreatedBy,
    AgencyId,
    CardPayment,
    CardPaymentFee,
    FileIdName,
    FileIdName2,
    TrpFee,
    UpdatedBy,
    UpdatedOn,
    LaminationFee,
    FileIdNamePermit,
    FileIdNameTrpT,
    FileIdNameTrpTBack,
    FileIdNameProofAddress,
    TelIsCheck,
    VinPertmitTrpId,
    VinNumber,
    HasId2,
    HasProofAddress,
    IdExpirationDate,
    FeeElsSale,
    FeeElsTrpSale,
    CashierCommission
    )
      VALUES (@PermitTypeId, @PermitNumber, @ClientName, @Telephone, @Email, @Usd, @Fee1, @Cash, @CreatedOn, @CreatedBy, @AgencyId, @CardPayment, @CardPaymentFee, @FileIdName, @FileIdName2, @TrpFee, @UpdatedBy, @UpdatedOn, @LaminationFee, @FileIdNamePermit, @FileIdNameTrpT, @FileIdNameTrpTBack, @FileIdNameProofAddress, @TelIsCheck, @VinPertmitTrpId, @VinNumber, @HasId2, @HasProofAddress, @IdExpirationDate,@FeeElsSale,
    @FeeElsTrpSale,@CashierCommission);
    SET @IdCreated = @@identity;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].[TRP]
    SET PermitTypeId = @PermitTypeId
       ,PermitNumber = @PermitNumber
       ,ClientName = @ClientName
       ,Telephone = @Telephone
       ,Email = @Email
       ,Usd = @Usd
       ,Fee1 = @Fee1
       ,Cash = @Cash
--       ,CreatedOn = @CreatedOn
--       ,CreatedBy = @CreatedBy
       ,CardPayment = @CardPayment
       ,CardPaymentFee = @CardPaymentFee
       ,FileIdName = @FileIdName
       ,FileIdName2 = @FileIdName2
       ,TrpFee = @TrpFee
       ,UpdatedBy = @UpdatedBy
       ,UpdatedOn = @UpdatedOn
       ,LaminationFee = @LaminationFee
       ,FileIdNamePermit = @FileIdNamePermit
       ,FileIdNameTrpT = @FileIdNameTrpT
       ,FileIdNameTrpTBack = @FileIdNameTrpTBack
       ,FileIdNameProofAddress = @FileIdNameProofAddress
       ,TelIsCheck = @TelIsCheck
       ,VinPertmitTrpId = @VinPertmitTrpId
       ,VinNumber = @VinNumber
       ,HasId2 = @HasId2
       ,HasProofAddress = @HasProofAddress,
       IdExpirationDate = @IdExpirationDate,
       FeeElsSale = @FeeElsSale,
       FeeElsTrpSale = @FeeElsTrpSale
    WHERE TRPId = @TRPId;
    SET @IdCreated = @TRPId;
  END;
END;



GO