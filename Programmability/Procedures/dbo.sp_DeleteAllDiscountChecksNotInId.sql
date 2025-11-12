SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllDiscountChecksNotInId]
(@DiscountChecksIdList VARCHAR(1000),
 @Date                        DATE,
  @AgencyId                    INT,
 @UserId                      INT
)
AS
     BEGIN
         DELETE FROM DiscountChecks
         WHERE DiscountCheckId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@DiscountChecksIdList)
         )
         AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
	     AND AgencyId = @AgencyId
         AND CreatedBy = @UserId;
     END;
GO