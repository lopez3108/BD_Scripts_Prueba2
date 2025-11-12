SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Retorna los archivos de un cheque retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetReturnFiles]
@ReturnedCheckId INT
		 AS
		  
BEGIN

SELECT [ReturnFilesId]
      ,[ReturnedCheckId]
      ,[Name]
      ,[CreationDate]
      ,[CreatedBy]
  FROM [dbo].[ReturnFiles]
  WHERE [ReturnedCheckId] = @ReturnedCheckId


END
GO