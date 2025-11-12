SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 8-03-23
--USO: VERIFICA TICKETNUMBER Y AGENCYID COMBINATION
CREATE PROCEDURE [dbo].[sp_VeriTicketNumberAndAgency] (@AgencyId  INt,
@TicketNumber  varchar(30))
AS

BEGIN
  IF EXISTS (SELECT top 1 TicketNumber FROM Tickets t WHERE t.AgencyId = @AgencyId AND t.TicketNumber = @TicketNumber)
  BEGIN
 SELECT top 1 t.TicketNumber, t.AgencyId, a.Code + ' - ' + a.Name AS Agency FROM Tickets t
       INNER JOIN Agencies a ON t.AgencyId = a.AgencyId
       WHERE t.AgencyId = @AgencyId AND t.TicketNumber = @TicketNumber
  END
ELSE IF EXISTS (SELECT top 1 td.TicketNumber FROM TicketFeeServiceDetails td WHERE td.AgencyId = @AgencyId AND td.TicketNumber = @TicketNumber ) 
BEGIN
     	 SELECT top 1 td.TicketNumber, td.AgencyId, a.Code + ' - ' + a.Name AS Agency FROM TicketFeeServiceDetails td
       INNER JOIN Agencies a ON td.AgencyId = a.AgencyId
       WHERE td.AgencyId = @AgencyId AND td.TicketNumber = @TicketNumber
END   

END;


GO