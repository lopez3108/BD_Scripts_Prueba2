SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTicketPaymentTypes] 
AS
     BEGIN
         SELECT *
         FROM TicketPaymentTypes        
         ORDER BY Description;
     END;
GO