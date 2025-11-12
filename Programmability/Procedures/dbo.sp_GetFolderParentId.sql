SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetFolderParentId] (
@PathResource VARCHAR(500) = NULL)
AS
BEGIN
DECLARE @parentid int, @count INT ;

set @count = (SELECT count(*) FROM PathsByUsers WHERE PathResource = @PathResource )

IF (@count > 1)  BEGIN  
	SELECT TOP 1  * FROM PathsByUsers pbu WHERE  pbu.PathResource = @PathResource ORDER BY pbu.PahtByUserId desc
END
ELSE
BEGIN
SELECT top 1 * FROM PathsByUsers pbu
 WHERE pbu.PathResource =  @PathResource
end

 
END

GO