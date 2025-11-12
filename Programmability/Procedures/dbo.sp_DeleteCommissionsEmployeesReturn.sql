SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Creation By jt, Date: 7-abril-2024 

CREATE PROCEDURE [dbo].[sp_DeleteCommissionsEmployeesReturn] (
@ExpenseId INT)

AS
BEGIN
  DELETE FROM CommissionsEmployeesReturn
  WHERE ExpenseId = @ExpenseId AND ExpensePaidId IS NULL--We only can remove an CommissionsEmployeesReturn when it not have payments 


UPDATE CommissionsEmployeesReturn SET ExpenseId = NULL WHERE ExpenseId = @ExpenseId AND ExpensePaidId IS NOT NULL --Ahora actualizamos el retorno que no se pudo eliminar
--en el delete atenrior y le desligamos el expenseid

--En este punto simplemente limpiamos la tabla donde los registros no tengan ni expense id ni ExpensePaidId
DELETE FROM CommissionsEmployeesReturn   WHERE ExpenseId  IS NULL AND ExpensePaidId IS NULL
END

GO