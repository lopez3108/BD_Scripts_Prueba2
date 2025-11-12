SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--OBTIENE TODOS LOS CAJEROS DEL SISTEMA ACTIVOS Y INACTIVOS.
--CREATEDBY: JOHAN
--19-04-2023
CREATE PROCEDURE [dbo].[sp_GetAllCashierList]
AS
     BEGIN
             SELECT DISTINCT
                Users.Name,
                Cashiers.CashierId,
                Users.UserId,
                Cashiers.IsActive               
         FROM Cashiers 
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
              ORDER BY  Users.Name
			   
                
     END;




GO