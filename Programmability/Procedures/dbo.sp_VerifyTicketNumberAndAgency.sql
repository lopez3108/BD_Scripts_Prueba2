SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 8-03-23
--USO: VERIFICA TICKETNUMBER Y AGENCYID COMBINATION
-- 2025-04-11 JF/6449: El número de ticket es único en razón del sistema
CREATE PROCEDURE [dbo].[sp_VerifyTicketNumberAndAgency] (@AgencyId INT, @TicketFeeServiceDetailsId INT = NULL,
@TicketNumber VARCHAR(30)
--@TicketNumber VARCHAR(500) = NULL
)
AS
BEGIN
  IF EXISTS (SELECT TOP 1
        TicketNumber
      FROM Tickets t
      WHERE 
--      t.AgencyId = @AgencyId AND por task 6449
      t.TicketNumber = @TicketNumber)
  BEGIN
    SELECT TOP 1
      t.TicketNumber
     ,t.AgencyId
     ,a.Code + ' - ' + a.Name AS Agency
    FROM Tickets t
    INNER JOIN Agencies a
      ON t.AgencyId = a.AgencyId
    WHERE
--    t.AgencyId = @AgencyId  AND por task 6449
    t.TicketNumber = @TicketNumber
  END


  ELSE
  IF EXISTS (SELECT TOP 1
        td.TicketNumber
      FROM TicketFeeServiceDetails td
      WHERE (TicketFeeServiceDetailsId != @TicketFeeServiceDetailsId
      OR @TicketFeeServiceDetailsId IS NULL)
--      AND td.AgencyId = @AgencyId por task 6449
      AND td.TicketNumber = @TicketNumber)
  BEGIN
    SELECT TOP 1
      td.TicketNumber
     ,td.AgencyId
     ,a.Code + ' - ' + a.Name AS Agency
    FROM TicketFeeServiceDetails td
    INNER JOIN Agencies a
      ON td.AgencyId = a.AgencyId
    WHERE
--    td.AgencyId = @AgencyId   AND por task 6449
    td.TicketNumber = @TicketNumber
  END

END;



GO