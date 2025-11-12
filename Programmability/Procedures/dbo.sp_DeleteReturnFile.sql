SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Elimina un archivo de un cheque retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteReturnFile]
@ReturnFilesId INT
		 AS
		  
BEGIN

DELETE ReturnFiles
  WHERE [ReturnFilesId] = @ReturnFilesId

  SELECT @ReturnFilesId

END
GO