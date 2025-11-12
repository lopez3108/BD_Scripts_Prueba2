SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateTicketFeeService]
(@TicketFeeServiceId INT            = NULL, 
 @Cash               DECIMAL(18, 2)  = NULL
)
AS
    BEGIN
        UPDATE [dbo].TicketFeeServices
          SET 
              Cash = @Cash
        WHERE TicketFeeServiceId = @TicketFeeServiceId;
    END;
GO