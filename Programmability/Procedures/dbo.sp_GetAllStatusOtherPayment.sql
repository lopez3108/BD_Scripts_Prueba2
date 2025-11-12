SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllStatusOtherPayment]
AS 
  SELECT * FROM PaymentOthersStatus pos
GO