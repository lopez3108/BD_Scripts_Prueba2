SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Retorna los tipos de pago de un cheque retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetReturnPaymentMode]
		 AS
		  
BEGIN

SELECT [ReturnPaymentModeId]
      ,[Description]
      ,[Code]
  FROM [dbo].[ReturnPaymentMode]



END
GO