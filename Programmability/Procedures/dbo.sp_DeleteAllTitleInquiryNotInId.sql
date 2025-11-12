SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllTitleInquiryNotInId]
(@TitleInquiryIdIdList VARCHAR(1000),
 @Date                 DATE,
 @AgencyId             INT,
 @UserId               INT
)
AS
     BEGIN
         DELETE FROM TitleInquiry
         WHERE TitleInquiryId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@TitleInquiryIdIdList)
         )
         AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
         AND AgencyId = @AgencyId
         AND CreatedBy = @UserId;
     END;
GO