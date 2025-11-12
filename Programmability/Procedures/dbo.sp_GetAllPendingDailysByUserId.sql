SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllPendingDailysByUserId] 
                                                           @UserId INT, 
                                                           @CurrentDate  DATE
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT 

                D.CashierId,
                D.AgencyId,
                D.CreationDate,               				
               (A.Code + ' - ' + A.Name) as Agency
        FROM daily D
             INNER JOIN Agencies a ON d.AgencyId = a.AgencyId
             INNER JOIN Cashiers u ON d.CashierId = u.CashierId
        WHERE(CAST(CreationDate AS DATE) <= CAST(@CurrentDate AS DATE))
        AND (D.ClosedBy IS NULL AND D.ClosedOn IS NULL)
             AND u.UserId = @UserId
         
       
    END;

GO