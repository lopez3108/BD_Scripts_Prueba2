SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllManagers] @UserId INT = NULL
AS
     BEGIN
         SELECT DISTINCT
                Users.Name,
                Users.[User] Email,
                Cashiers.CashierId,
                Users.UserId,
                Cashiers.IsActive,
				Users.Telephone
         FROM Cashiers
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
		    WHERE Cashiers.IsManager = 1
			ORDER BY Users.Name
     END;
GO