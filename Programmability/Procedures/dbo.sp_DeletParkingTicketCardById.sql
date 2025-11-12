SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletParkingTicketCardById](@ParkingTicketCardId INT)
AS
    BEGIN
        DELETE FROM ParkingTicketsCards
        WHERE ParkingTicketCardId = @ParkingTicketCardId;
    END;
GO