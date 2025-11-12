SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetParkingTicketById]
(@ParkingTicketId    INT  )
AS
     BEGIN
         SELECT  p.ParkingTicketId,
                 p.Usd,
				 p.Fee1,
				 p.Fee2,
				 p.CreationDate
				                        
         FROM  ParkingTickets p 
         WHERE P.ParkingTicketId = @ParkingTicketId
     END;
GO