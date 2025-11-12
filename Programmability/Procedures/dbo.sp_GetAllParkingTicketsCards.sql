SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllParkingTicketsCards]
(@Creationdate DATE = NULL, 
 @AgencyId     INT, 
 @UserId       INT  = NULL
)
AS
    BEGIN
        SELECT *, 
               TicketPaymentTypes.Code PaymentTypeCode, 
               usu.Name UpdatedByName
        FROM ParkingTicketsCards
             LEFT JOIN Users usu ON UpdatedBy = usu.UserId
             INNER JOIN TicketPaymentTypes ON ParkingTicketsCards.TicketPaymentTypeId = TicketPaymentTypes.TicketPaymentTypeId
        WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
              OR @CreationDate IS NULL)
             AND AgencyId = @AgencyId
             AND (CreatedBy = @UserId
                  OR @UserId IS NULL);
    END;
GO