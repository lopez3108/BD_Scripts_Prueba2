SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetGetPathResourceByUser]
(@UserId INT = NULL,
@ParentId INT = NULL, 
@PathResource varchar(500)= NULL,
@PathResourceChild varchar(500)= NULL)
AS
BEGIN
	SELECT *
	FROM PathsByUsers P LEFT JOIN PathsByUsers C ON P.PahtByUserId = C.ParentId 
	AND C.PathResource = @PathResourceChild 
	--CASE WHEN  @PathResourceChild <> NULL THEN C.ParentId ELSE NULL END  
	--AND C.PathResource = @PathResourceChild AND @PathResourceChild <> NULL
	WHERE
	(P.CreatedBy = @UserId OR @UserId IS NULL) AND
	(P.PathResource = @PathResource OR @PathResource IS NULL) AND
	--(C.PathResource = @PathResourceChild OR @PathResourceChild IS NULL) AND
	(P.ParentId = @ParentId OR @ParentId IS NULL)
END
GO