SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Update By:     Felipe
-- Creation Date: 08-abril-2024
-- Task:          Delete only the main feeService, the detail deletes it in another sp

CREATE PROCEDURE [dbo].[sp_DeleteTicketFeeServiceById](@TicketFeeServiceId INT)
AS
    BEGIN
--        DELETE FROM TicketFeeServiceDetails
--        WHERE TicketFeeServiceId = @TicketFeeServiceId;

        DELETE FROM TicketFeeServices
        WHERE TicketFeeServiceId = @TicketFeeServiceId;
    END;

GO