SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create PROCEDURE [dbo].[sp_GetAllPaymentTypesPorperties]
AS 
  SELECT * FROM dbo.PaymentTypesProperties ps
GO