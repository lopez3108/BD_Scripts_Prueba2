SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTicketsByIdAgencyDaily] @AgencyId     INT,
                                                         @CreationDate DATE = NULL,
                                                         @UserId       INT
AS
     BEGIN
         SELECT ISNULL(SUM(t.Usd) , 0) Usd,
                 ISNULL(SUM(t.Fee1), 0) Fee1,
                ISNULL(SUM(t.Fee2), 0) Fee2
         FROM Tickets t
              INNER JOIN TicketStatus ts ON t.TicketStatusId = ts.TicketStatusId
              INNER JOIN Users u ON u.UserId = t.CreatedBy
              INNER JOIN Agencies a ON a.AgencyId = t.AgencyId
              LEFT JOIN Users uc ON uc.UserId = t.CompletedBy
         WHERE t.AgencyId = @AgencyId
               AND (CAST(t.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                    OR @CreationDate IS NULL)
               AND T.CreatedBy = @UserId;
     END;

GO