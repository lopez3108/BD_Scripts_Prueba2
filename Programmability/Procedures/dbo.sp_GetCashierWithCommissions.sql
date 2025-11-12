SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATED BY  JOHAN
--CREATED ON 20/11/2023
-- USO TRAE CAJERO CON COMISIONES PENDIENTES CON RANGO DE FECHA

--Updated 2024-04-02 felipe/ User Story 5678: Check the cashiers by agency that are related or that have movements

--UPDATET BY : JT/03-03-2024 TASK 5834 List employees commissions only show employees with commission pendings

CREATE PROCEDURE [dbo].[sp_GetCashierWithCommissions] (@DateFrom DATETIME = NULL, @DateTo DATETIME = NULL, @AgencyId INT,@OnlyPendings BIT = NULL)
AS

BEGIN
  SELECT DISTINCT
    U.Name
   ,U.UserId
   ,C.CashierId

  FROM Users U
  INNER JOIN Cashiers C
    ON C.UserId = U.UserId
--  INNER JOIN AgenciesxUser au
--    ON au.UserId = U.UserId
  WHERE 
--  au.AgencyId = @AgencyId
--  OR 
  (SELECT
      dbo.fn_VaidatedCashierWithCommissions(@DateFrom, @DateTo, C.CashierId, @AgencyId, @OnlyPendings))
  > 0
  ORDER BY U.Name ASC;
END;









GO