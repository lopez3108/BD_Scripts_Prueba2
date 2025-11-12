SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTitleInquiry]
(@Creationdate DATE = NULL, 
 @AgencyId     INT, 
 @UserId       INT  = NULL
)
AS
    BEGIN
        SELECT *, 
               usu.Name UpdatedByName
        FROM TitleInquiry
             LEFT JOIN Users usu ON UpdatedBy = usu.UserId
        WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
              OR @CreationDate IS NULL)
             AND AgencyId = @AgencyId
             AND (CreatedBy = @UserId
                  OR @UserId IS NULL);
    END;
GO