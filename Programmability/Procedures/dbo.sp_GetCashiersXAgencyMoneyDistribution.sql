SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCashiersXAgencyMoneyDistribution] @AgencyId INT = NULL
AS
    BEGIN
        SELECT DISTINCT
               Cashiers.CashierId, 
               Users.Name, 
               Users.UserId, 
             --  AgenciesxUser.AgencyId, 
               Cashiers.IsActive
        FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
        WHERE (Cashiers.CashierId NOT IN (SELECT CashierId FROM  MoneyDistribution))
        ORDER By Users.Name ASC;
    END;



	
GO