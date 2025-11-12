SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDiscountTitlesDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT = NULL
)
AS
     BEGIN
        SELECT d.DiscountTitleId,
                d.TitleId,
                d.Discount,
                d.Usd,
                d.ReasonId,
                d.OtherReason,
                d.CreationDate,
                d.CreatedBy,
                d.AgencyId,
                T.ProcessTypeId,
                pt.Code AS ProcessTypeCode,
                pt.Description AS ProcessTypeDescription,
                T.DeliveryTypeId,
                dt.Code AS DeliveryTypeCode,
                dt.Description AS DeliveryTypeDescription,
                T.PlateTypeId,
                pts.Code AS PlateTypeCode,
                pts.Description AS PlateTypeDescription,
                T.ProcessStatusId,
                ps.Code AS ProcessStatusCode,
                ps.Description AS ProcessStatusDescription,
                T.DeliveryBY,
                ISNULL(T.Name, NULL) Name,
                UPPER(ISNULL(T.Name, NULL))+' - '+UPPER(pt.Description) AS TitleProcessType,
				(pt.Description) AS TitleProcessType2,
                T.Telephone,
                r.Code ReasonCode,
				 d.LastUpdatedOn,
				 d.LastUpdatedBy,
				 usu.Name LastUpdatedByName,
				  ISNULL(d.TelIsCheck , CAST(0 AS BIT)) TelIsCheck,
		   d.ActualClientTelephone
         FROM DiscountTitles d
              LEFT JOIN Reasons r ON d.ReasonId = r.ReasonId
              INNER JOIN Titles t ON d.TitleId = t.TitleId
              LEFT JOIN ProcessTypes pt ON t.ProcessTypeId = pt.ProcessTypeId
              LEFT JOIN DeliveryTypes dt ON t.DeliveryTypeId = dt.DeliveryTypeId
              LEFT JOIN PlateTypes pts ON t.PlateTypeId = pts.PlateTypeId
              INNER JOIN Users us ON t.CreatedBy = us.UserId
              LEFT JOIN PlateTypesPersonalized ptp ON t.PlateTypePersonalizedId = ptp.PlateTypePersonalizedId
              LEFT JOIN Users usu ON t.UpdatedBy = usu.UserId
              LEFT JOIN ProcessStatus ps ON t.ProcessStatusId = ps.ProcessStatusId
         WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND d.AgencyId = @AgencyId
              AND (d.CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO