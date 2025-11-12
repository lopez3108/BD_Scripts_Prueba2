SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashierResumeToday]
 @DateCashed datetime,
 @CashierId int
AS 

BEGIN
SELECT     SUM(Checks.Amount) as Cashed, COUNT(Checks.CheckId) as NumberChecks, SUM(dbo.fn_GetCheckEarning(CheckId)) as Earnings
FROM            Checks INNER JOIN
                         Cashiers ON Checks.CashierId = Cashiers.CashierId INNER JOIN
                         Clientes ON Checks.ClientId = Clientes.ClienteId INNER JOIN
                         Users ON Clientes.UsuarioId = Users.UserId INNER JOIN
                         Users AS Users_1 ON Cashiers.UserId = Users_1.UserId INNER JOIN
                         Makers ON Checks.Maker = Makers.MakerId INNER JOIN
                         Agencies ON Checks.AgencyId = Agencies.AgencyId
						 WHERE
						 CAST(Checks.DateCashed as DATE) = CAST(@DateCashed as datetime) AND
						 Checks.CashierId = @CashierId
	END


GO