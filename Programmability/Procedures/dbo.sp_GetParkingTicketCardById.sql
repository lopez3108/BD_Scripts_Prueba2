SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetParkingTicketCardById]
(@ParkingTicketCardId    INT  )
AS
     BEGIN
         SELECT  p.ParkingTicketCardId,
                 p.Usd,
				 p.Fee1,
				 p.Fee2,
				 p.CreationDate
				                        
         FROM  ParkingTicketsCards p 
         WHERE P.ParkingTicketCardId = @ParkingTicketCardId
     END;
GO