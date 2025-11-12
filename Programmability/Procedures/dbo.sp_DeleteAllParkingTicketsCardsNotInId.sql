SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllParkingTicketsCardsNotInId]
(@ParkingTicketCardIdList VARCHAR(1000),
 @Date                    DATE,
 @AgencyId                INT,
 @UserId                  INT
)
AS
     BEGIN
         DELETE FROM ParkingTicketsCards
         WHERE ParkingTicketCardId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@ParkingTicketCardIdList)
         )
         AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
         AND AgencyId = @AgencyId
         AND CreatedBy = @UserId;
     END;
GO