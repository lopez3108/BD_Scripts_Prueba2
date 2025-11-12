SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteFile]
 (
	  
	  @FileId int

    )
AS 

BEGIN

DELETE FROM [dbo].[Files]
      WHERE FileId = @FileId


	END


GO