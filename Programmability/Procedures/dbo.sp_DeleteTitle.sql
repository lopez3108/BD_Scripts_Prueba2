SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteTitle](@TitleId INT)
AS
     BEGIN
         DELETE FROM PromotionalCodesStatus
         WHERE TitleId = @TitleId;

         DELETE FROM Titles
         WHERE TitleId = @TitleId;

         DELETE FROM CheckListResult
         WHERE TitleId = @TitleId;
     END;

GO