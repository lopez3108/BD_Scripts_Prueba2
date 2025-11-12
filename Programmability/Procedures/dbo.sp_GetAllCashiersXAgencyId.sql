SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      sa
-- Create date: 12/09/2024 2:34 p. m.
-- Database:    developing
-- Description: task 6051 Agregar un nuevo filtro al reporte others services 
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetAllCashiersXAgencyId] 
@AgencyId INT = NULL 
                                              
AS
    BEGIN
        SELECT DISTINCT
               Users.Name, 
               Users.UserId,
               Cashiers.CashierId,
               AgenciesxUser.AgencyId,
               Cashiers.IsActive


         
     FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
        WHERE( AgenciesxUser.AgencyId = @AgencyId OR @AgencyId IS NULL )
            
        ORDER By Users.Name ASC;
    END;
GO