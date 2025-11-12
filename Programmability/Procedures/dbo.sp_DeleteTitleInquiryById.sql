SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteTitleInquiryById](@TitleInquiryId INT)
AS
    BEGIN
        DELETE FROM TitleInquiry
        WHERE TitleInquiryId = @TitleInquiryId;
    END;
GO