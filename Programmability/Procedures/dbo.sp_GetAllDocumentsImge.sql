SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllDocumentsImge]
 
 @DocumentId int

AS 

BEGIN

SELECT        Doc1Front, Doc1Back,'' as Doc2Front, '' as Doc2Back
FROM            Documents
WHERE DocumentId = @DocumentId
	
	END


GO