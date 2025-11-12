SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTitlesDailyCashier]
(@CreationDate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT  = NULL
)
AS
     BEGIN
         SELECT T.TitleId,
                --UPPER(T.Name)+' - '+UPPER(pt.Description) AS TitleProcessType,
				UPPER(ISNULL(T.Name, ''))+ CASE WHEN T.Name IS NOT NULL  AND T.Name <> '' THEN  ' - ' ELSE '' END + UPPER(pt.Description) AS TitleProcessType,
                T.Telephone
         FROM TITLES t
              LEFT JOIN DeliveryTypes dt ON t.DeliveryTypeId = dt.DeliveryTypeId
              INNER JOIN Users us ON t.CreatedBy = us.UserId
              LEFT JOIN PlateTypes pts ON t.PlateTypeId = pts.PlateTypeId
              INNER JOIN ProcessTypes pt ON t.ProcessTypeId = pt.ProcessTypeId
              LEFT JOIN PlateTypesPersonalized ptp ON t.PlateTypePersonalizedId = ptp.PlateTypePersonalizedId
              LEFT JOIN Users usu ON t.UpdatedBy = usu.UserId
              LEFT JOIN ProcessStatus ps ON t.ProcessStatusId = ps.ProcessStatusId
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND t.AgencyId = @AgencyId
              AND (t.CreatedBy = @UserId
                   OR @UserId IS NULL);
     END;
GO