SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePasswordAccess]
(
	  @PassAccessId int
)
AS 

BEGIN

	DELETE FROM [dbo].[PassAccess]
	WHERE PassAccessId = @PassAccessId

	SELECT 1

END
GO