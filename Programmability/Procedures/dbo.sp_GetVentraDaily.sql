SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetVentraDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT = NULL
)
AS
     BEGIN
         SELECT ISNULL(VentraId, 0) VentraId,
                ReloadQuantity,
                ReloadUsd,
                CreatedBy,
                CreationDate,
                AgencyId,
                ISNULL(v.ReloadQuantity , 0) NumberTransactions,
                ISNULL(v.ReloadUsd , 0) Total,
				 v.LastUpdatedOn,
         usu.Name LastUpdatedByName
         FROM Ventra v
		  LEFT JOIN Users usu ON v.LastUpdatedBy = usu.UserId
         WHERE(CAST(v.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND v.AgencyId = @AgencyId
              AND (v.CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO