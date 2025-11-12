SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDiscountMoneyTransferDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId     INT = NULL
)
AS
     BEGIN
         SELECT *,
		  usu.Name LastUpdatedByName,
		   ISNULL(m.TelIsCheck , CAST(0 AS BIT)) TelIsCheck
		   --m.ActualClientTelephone as ActualClientTelephoneSaved
         FROM DiscountMoneyTransfers m
		 LEFT JOIN Users usu ON LastUpdatedBy = usu.UserId
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND AgencyId = @AgencyId
		     AND (CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO