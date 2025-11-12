SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCahiersNotInDistribution]
AS
     BEGIN
         SELECT UPPER(Users.Name) Name,
                Cashiers.CashierId,
                Users.UserId
         FROM Cashiers
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
         WHERE Cashiers.CashierId NOT IN
         (
             SELECT m.CashierId
             FROM MoneyDistribution m
         ) AND Cashiers.IsActive = 1;
     END;
GO