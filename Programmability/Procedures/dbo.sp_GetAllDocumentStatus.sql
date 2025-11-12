SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDocumentStatus] @Code VARCHAR(200) = NULL
AS
     BEGIN
         SELECT *
         FROM DocumentStatus
         WHERE DocumentStatus.Code IN(@Code)
         OR @Code IS NULL
         OR @Code = ''
         ORDER BY DocumentStatus.Code;
     END;
GO