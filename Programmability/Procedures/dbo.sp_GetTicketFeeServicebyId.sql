SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Created By:     Felipe
-- Creation Date: 08-abril-2024
-- Task:          removed TicketFeeService details

CREATE PROCEDURE [dbo].[sp_GetTicketFeeServicebyId] (@TicketFeeServiceId INT)
AS
BEGIN
  
  SELECT tfsd.TicketFeeServiceDetailsId
  FROM  TicketFeeServiceDetails tfsd 
  WHERE tfsd.TicketFeeServiceId = @TicketFeeServiceId
    
END;


GO