SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetChecksElsDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT
)
AS
     BEGIN
         SELECT *
         FROM [dbo].[ChecksEls]
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND AgencyId = @AgencyId;
     END;
GO