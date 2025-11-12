SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-06-22 DJ/5923: City sticker created from Title and Plates form
-- Description: task 5987 Cuando se crea un city sticker desde un title no se está teniendo en cuenta el fee els
-- 2025-06-09 JF/6571: Guardar valor de descuento aplicado en el momento del registro y no por referencia a configuración


CREATE PROCEDURE [dbo].[sp_GetAllTitles] (@CreationDate DATE = NULL,
@Name VARCHAR(70) = NULL,
@Telephone VARCHAR(10) = NULL,
@PlateNumber VARCHAR(20) = NULL,
@ProcessTypeId INT = NULL,
@ProcessStatusId INT = NULL,
@AgencyId INT,
--@ProcessAuto     BIT         = NULL,
@UserId INT = NULL,
@PackageNumber VARCHAR(15) = NULL,
@FromDate DATE = NULL,
@ToDate DATE = NULL,
@VinNumber VARCHAR(50) = NULL)
AS
BEGIN
  SELECT DISTINCT
    t.TitleId
   ,ISNULL(t.ProcessTypeId, 0) ProcessTypeId
   ,ISNULL(t.ProcessTypeId, 0) ProcessTypeIdInit
   ,pt.Code AS ProcessTypeCode
   ,pt.Description AS ProcessTypeDescription
   ,t.DeliveryTypeId
   ,dt.Code AS DeliveryTypeCode
   ,dt.Description AS DeliveryTypeDescription
   ,t.PlateTypeId
   ,pts.Code AS PlateTypeCode
   ,pts.Code AS PlateTypeCodeSaved
   ,pts.Description AS PlateTypeDescription
   ,t.ProcessStatusId
   ,ps.Code AS ProcessStatusCode
   ,ps.Code AS ProcessStatusCodeChange
   ,ps.Description AS ProcessStatusDescription
   ,t.DeliveryBy
   ,ISNULL(t.Name, NULL) Name
   ,ISNULL(t.Name, NULL) ClientName
   ,UPPER(t.Name) + ' - ' + UPPER(pt.Description) AS TitleProcessType
   ,t.Telephone
   ,t.Email
   ,t.PlateNumber
   ,t.USD
   ,t.Fee1
   ,t.Fee1 Fee1Init
   ,t.PackageNumber
   ,t.DeliveredPackageDate
   ,t.CreatedBy
   ,us.Name CreatedByName
   ,t.UpdatedBy
   ,t.UpdatedOn
   ,usu.Name UpdatedByName
   ,ISNULL(t.Financial, 0) Financial
   ,t.Dunbar
   ,t.CreationDate
   ,FORMAT(t.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(t.UpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdatedOnFormat
   ,FORMAT(t.DatePendingState, 'MM-dd-yyyy h:mm:ss tt', 'en-US') DatePendingStateFormat
   ,FORMAT(t.DatePending, 'MM-dd-yyyy h:mm:ss tt', 'en-US') DatePendingFormat
   ,FORMAT(t.DateReceived, 'MM-dd-yyyy h:mm:ss tt', 'en-US') DateReceivedFormat
   ,FORMAT(t.DateCompleted, 'MM-dd-yyyy h:mm:ss tt', 'en-US') DateCompletedFormat
   ,FORMAT(t.DeliveredPackageDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') DeliveredPackageDateFormat
   ,FORMAT(t.Dunbar, 'MM-dd-yyyy', 'en-US') DunbarFormat
   ,t.CardPayment
   ,t.CardPaymentFee
   ,t.FeeEls
   ,t.FeeEls FeeElsInit
   ,t.FileIdName
   ,t.FileIdName2
   ,t.FileIdNameTitle AS FileIdNameEls
   ,t.FileIdNameTitleBack
   ,t.FileIdNameElsCopy
   ,t.FileIdNameTitleM
   ,t.FileIdNameTitleMBack
   ,t.FileIdNameMoIlsos
   ,t.FileIdNameMo
   ,t.FileIdNameRut
   ,t.FileIdNameVehicle
   ,t.FileIdNameAttorney
   ,t.FileIdNameProofAddress
   ,ISNULL(t.SellerId, 0) SellerId
   ,pt.ProcessAuto ProcessAutoProcessType
   ,ISNULL(t.FeeILDOR, 0) FeeILDOR
   ,ISNULL(t.MOILDOR, 0) MOILDOR
   ,ISNULL(t.FeeILSOS, 0) FeeILSOS
   ,ISNULL(t.BuyingPrice, 0) BuyingPrice
   ,ISNULL(t.MOLSOS, 0) MOLSOS
   ,ISNULL(t.FeeOther, 0) FeeOther
   ,ISNULL(t.MOOther, 0) MOOther
   ,ISNULL(t.RunnerService, 0) RunnerService
   ,t.ProcessAuto
   ,t.PlateTypePersonalizedId
   ,t.PlateTypeOtherTruckId
   ,t.PlateTypePersonalizedId AS PlateTypePersonalizedIdSaved
   ,t.PlateTypeOtherTruckId AS PlateTypeOtherTruckIdSaved
   ,t.PlateTypeTrailerId
   ,t.PlateTypeTrailerId AS PlateTypeTrailerIdSaved
   ,ISNULL(t.FinancingId, 0) FinancingId
   ,ISNULL(t.PlateTypePersonalizedFee, 0) PlateTypePersonalizedFee
   ,ptp.Description PlateTypePersonalizedDescription
   ,pto.Description PlateTypeOtherDescription
   ,ptt.Description PlateTypeTrailerDescription
   ,ISNULL(F.Trp, '') Trp
   ,ISNULL(F.Name + '-' + F.Trp, '') ClientTrp
   ,a.AgencyId
   ,a.Name AgencyName
   ,a.Code
   ,(a.Code + ' - ' + a.Name) CodeAgencyName
   ,a.Telephone AgencyPhone
   ,a.Address AgencyAddress
   ,ISNULL(P.PromotionalCodeStatusId, 0) PromotionalCodeStatusId
   ,ISNULL(P.PromotionalCodeId, 0) PromotionalCodeId
   ,ISNULL(p.Usd, 0) UsdDiscount
   ,ISNULL(t.TelIsCheck, CAST(0 AS BIT)) TelIsCheck
   ,ISNULL(t.ExpenseId, 0) ExpenseTitleId
   ,ISNULL(t.CashierCommission, 0) CashierCommissionTitle
   ,c.CashierId
   ,usu.Name UpdatedByName
   ,usu.Name DeliveryByName
   ,pd.PlateDesignId
   ,pd.PlateDesignId AS PlateDesignIdSaved
   ,pd.Code AS PlateDesignCode
   ,pd.Description AS PlateDesignDescription
   ,t.DatePendingState
   ,t.DatePending
   ,t.DateReceived
   ,t.DateCompleted
   ,t.DatePendingStateBy
   ,t.DatePendingBy
   ,t.DateReceivedBy
   ,t.DateCompletedBy
   ,t.Cash
   ,usus.Name PendingStateBy
   ,usup.Name PendingBy
   ,usur.Name ReceivedBy
   ,usuc.Name CompletedBy
   ,t.ChooseMsg
   ,t.VinNumber
   ,(SELECT TOP 1
        nt.Note
      FROM NotesXTitles nt
      WHERE nt.TitleId = t.TitleId
      AND IsPrincipalNote = 1)
    AS Note
   ,CAST(t.HasId2 AS BIT) HasId2
   ,CAST(t.HasProofAddress AS BIT) HasProofAddress
   ,CAST(IdExpirationDate AS DATE) AS IdExpirationDate
   ,FORMAT(t.IdExpirationDate, 'MM-dd-yyyy', 'en-US') IdExpirationDateFormat
   ,cty.USD AS CityStickerUsd
   ,cty.Fee1 AS CityStickerFee1
   ,cty.FeeEls AS CityStickerFeeEls
   ,cty.CityStickerId
  FROM Titles t
  LEFT JOIN DeliveryTypes dt
    ON t.DeliveryTypeId = dt.DeliveryTypeId
  LEFT JOIN SellerStatus ss
    ON t.SellerId = ss.SellerId
  INNER JOIN Users us
    ON t.CreatedBy = us.UserId
  INNER JOIN Cashiers c
    ON c.UserId = us.UserId
  INNER JOIN Agencies a
    ON a.AgencyId = t.AgencyId
  LEFT JOIN PlateTypes pts
    ON t.PlateTypeId = pts.PlateTypeId
  LEFT JOIN ProcessTypes pt
    ON t.ProcessTypeId = pt.ProcessTypeId
  LEFT JOIN PromotionalCodesStatus P
    ON t.TitleId = P.TitleId
  LEFT JOIN PromotionalCodes pc
    ON pc.PromotionalCodeId = P.PromotionalCodeId
  LEFT JOIN PlateTypesPersonalized ptp
    ON t.PlateTypePersonalizedId = ptp.PlateTypePersonalizedId
  LEFT JOIN PlateTypeOtherTruck pto
    ON t.PlateTypeOtherTruckId = pto.PlateTypeOtherTruckId
  LEFT JOIN PlateTypeTrailer ptt
    ON t.PlateTypeTrailerId = ptt.PlateTypeTrailerId
  LEFT JOIN Users usu
    ON t.UpdatedBy = usu.UserId
  LEFT JOIN Users usus
    ON t.DatePendingStateBy = usus.UserId
  LEFT JOIN Users usup
    ON t.DatePendingBy = usup.UserId
  LEFT JOIN Users usur
    ON t.DateReceivedBy = usur.UserId
  LEFT JOIN Users usuc
    ON t.DateCompletedBy = usuc.UserId
  LEFT JOIN ProcessStatus ps
    ON t.ProcessStatusId = ps.ProcessStatusId
  LEFT JOIN Financing F
    ON F.FinancingId = t.FinancingId
  LEFT JOIN DiscountTitles DTS
    ON DTS.TitleId = t.TitleId
  LEFT JOIN PlateDesign pd
    ON pd.PlateDesignId = t.PlateDesignId
  LEFT JOIN dbo.CityStickers cty
    ON cty.TitleParentId = t.TitleId
  WHERE (CAST(t.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
  OR @CreationDate IS NULL)
  AND (t.Name LIKE '%' + @Name + '%'
  OR @Name IS NULL)
  AND (t.Telephone LIKE '%' + @Telephone + '%'
  OR @Telephone IS NULL)
  AND (t.PlateNumber LIKE '%' + @PlateNumber + '%'
  OR @PlateNumber IS NULL)
  AND (t.ProcessTypeId = @ProcessTypeId
  OR @ProcessTypeId IS NULL)
  AND (t.ProcessStatusId = @ProcessStatusId
  OR @ProcessStatusId IS NULL)
  AND t.AgencyId = @AgencyId
  --AND (t.ProcessAuto = @ProcessAuto
  --     OR @ProcessAuto IS NULL)
  AND (t.PackageNumber = @PackageNumber
  OR @PackageNumber IS NULL)
  AND (t.CreatedBy = @UserId
  OR @UserId IS NULL)
  AND (CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  --             AND (t.VinNumber = @VinNumber
  --                  OR @VinNumber IS NULL)
  AND (t.VinNumber LIKE '%' + @VinNumber + '%'
  OR @VinNumber IS NULL)
  ORDER BY CreationDate DESC;
END;










GO