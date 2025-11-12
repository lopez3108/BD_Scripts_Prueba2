SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDiscountPhonesDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @UserId     INT = NULL
)
AS
     BEGIN
         SELECT *,
		 usu.Name LastUpdatedByName,
		  ISNULL(p.TelIsCheck , CAST(0 AS BIT)) TelIsCheck
         FROM DiscountPhones p
		  LEFT JOIN Users usu ON p.LastUpdatedBy = usu.UserId
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND p.AgencyId = @AgencyId 
		    AND (p.CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO