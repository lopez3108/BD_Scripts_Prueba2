SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDiscountCheckAgencyByNumberByDate]
(@Number          VARCHAR(50),
 @DiscountCheckId INT         = NULL,
 @AgencyId        INT,
 @CreationDate    DATE,
 @Account VARCHAR(50)= NULL
)
AS
     BEGIN
         SELECT *
         FROM DiscountChecks
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND AgencyId = @AgencyId
              AND CheckNumber = @Number
              AND Account = @Account
              AND (DiscountCheckId <> @DiscountCheckId
                   OR @DiscountCheckId IS NULL);
     END;
GO