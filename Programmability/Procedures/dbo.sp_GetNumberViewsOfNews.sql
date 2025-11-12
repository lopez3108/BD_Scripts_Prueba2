SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberViewsOfNews] @NewsId     INT = NULL
                                             
AS
BEGIN
    SELECT COUNT(vu.NewsId ) NumberViews FROM  NewsXUsers vu 
    WHERE vu.NewsId = @NewsId
     END;
GO