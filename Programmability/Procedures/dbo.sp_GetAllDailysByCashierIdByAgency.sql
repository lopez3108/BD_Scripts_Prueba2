SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllDailysByCashierIdByAgency] @AgencyId  INT, 
                                                           @CashierId INT, 
                                                           @LastDate  DATE
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT CAST(YEAR(CAST(CreationDate AS DATE)) AS VARCHAR(10)) YearDaily, 
               CAST(MONTH(CAST(CreationDate AS DATE)) AS VARCHAR(10)) MonthDaily, 
               d.CashierId, 
               d.AgencyId, 
               CAST(u.ValidComissions AS DATE) ValidComissions
        FROM daily D
             INNER JOIN Agencies a ON d.AgencyId = a.AgencyId
             INNER JOIN Cashiers u ON d.CashierId = u.CashierId
        WHERE(CAST(CreationDate AS DATE) <= CAST(@LastDate AS DATE))
             AND (d.AgencyId = @AgencyId)
             AND d.CashierId = @CashierId
        GROUP BY d.CashierId, 
                 d.AgencyId, 
                
                  CAST(MONTH(CAST(CreationDate AS DATE)) AS INT),
        CAST(YEAR(CAST(CreationDate AS DATE)) AS INT),
                 u.ValidComissions
                
         
        ORDER BY
        CAST(YEAR(CAST(CreationDate AS DATE)) AS INT) ASC,
         CAST(MONTH(CAST(CreationDate AS DATE)) AS INT)ASC
        
        
        
         
                
--                 d.CashierId;
    END;

GO