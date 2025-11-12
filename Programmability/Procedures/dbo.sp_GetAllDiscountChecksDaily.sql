SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDiscountChecksDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
  @UserId     INT = NULL
)
AS
     BEGIN
         SELECT *,
		 usu.Name LastUpdatedByName,
		  ISNULL(c.TelIsCheck , CAST(0 AS BIT)) TelIsCheck
         FROM DiscountChecks c
		 LEFT JOIN Users usu ON c.LastUpdatedBy = usu.UserId
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND c.AgencyId = @AgencyId
		    AND (c.CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO