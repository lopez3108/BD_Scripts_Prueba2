SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetFeePlateStickersDaily]
(@CreationDate DATE = NULL,
 @AgencyId     INT,
 @UserId       INT
)
AS
     BEGIN
         SELECT SUM(Fee1) Fee
         FROM PlateStickers
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND AgencyId = @AgencyId
              AND CreatedBy = @UserId;
     END;
GO