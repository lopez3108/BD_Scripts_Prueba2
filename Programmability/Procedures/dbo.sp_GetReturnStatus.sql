SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Selecciona status retorno
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetReturnStatus]

		 AS
		  
BEGIN

SELECT [ReturnStatusId]
      ,[Description]
      ,[Code]
  FROM [dbo].[ReturnStatus]



END
GO