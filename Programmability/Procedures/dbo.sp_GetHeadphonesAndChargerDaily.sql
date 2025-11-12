SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetHeadphonesAndChargerDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT  = NULL,
 @IsHeadPhone  BIT  = NULL
)
AS
     BEGIN
         SELECT ISNULL(HeadphonesAndChargerId, 0) HeadphonesAndChargerId,
                ISNULL(HeadphonesQuantity, 0) HeadphonesQuantity,
                ISNULL(HeadphonesUsd, 0) HeadphonesUsd,
                ISNULL(ChargersQuantity, 0) ChargersQuantity,
                ISNULL(ChargersUsd, 0) ChargersUsd,
                ISNULL(HeadphonesQuantity, 0) HeadphonesQuantitySaved,
                ISNULL(HeadphonesUsd, 0) HeadphonesUsdSaved,
                ISNULL(ChargersQuantity, 0) ChargersQuantitySaved,
                ISNULL(ChargersUsd, 0) ChargersUsdSaved,
				CardPayment CardPayment,
                ISNULL(CardPaymentFee, 0) CardPaymentFee,	
				CardPayment CardPaymentSaved,
                ISNULL(CardPaymentFee, 0) CardPaymentFeeSaved,
				
                CreatedBy,
                CreationDate,
                AgencyId,
			 UpdatedBy,
			 UpdatedOn,
			  usu.Name UpdatedByName,
                ISNULL(v.HeadphonesQuantity + ChargersQuantity, 0) NumberTransactions,
                ISNULL(v.HeadphonesUsd + ChargersUsd, 0) Total
         FROM HeadphonesAndChargers v
		  LEFT JOIN Users usu ON UpdatedBy = usu.UserId
         WHERE(CAST(v.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND v.AgencyId = @AgencyId
              AND (v.CreatedBy = @UserId
                   OR @UserId IS NULL)
              AND ((v.HeadphonesQuantity > 0
                    AND @IsHeadPhone = 1)
                   OR (v.ChargersQuantity > 0
                       AND @IsHeadPhone = 0)
                   OR @IsHeadPhone IS NULL);
     END;
GO