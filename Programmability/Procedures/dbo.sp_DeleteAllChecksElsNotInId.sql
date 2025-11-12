SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllChecksElsNotInId]
(@ChecksElsIdList VARCHAR(1000),
 @Date            DATE,
 @AgencyId        INT,
 @ProviderTypeId  INT,
 @UserId          INT
)
AS
     BEGIN
         DELETE ps
         FROM PromotionalCodesStatus ps
         WHERE CheckId IN
         (
             SELECT C.CheckElsId
             FROM ChecksEls c
             WHERE CheckElsId NOT IN
             (
                 SELECT item
                 FROM dbo.FN_ListToTableInt(@ChecksElsIdList)
             )
             AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
             AND AgencyId = @AgencyId
             AND ProviderTypeId = @ProviderTypeId
             AND CreatedBy = @UserId
         );
         DELETE FROM ChecksEls
         WHERE CheckElsId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@ChecksElsIdList)
         )
         AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
         AND AgencyId = @AgencyId
         AND ProviderTypeId = @ProviderTypeId
         AND CreatedBy = @UserId;
     END;
GO