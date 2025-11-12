SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCashiersXAgencyExceptCashierId]
(@UserId   INT = NULL,
 @AgencyId INT
)
AS
     BEGIN
         SELECT Users.Name,
                Cashiers.CashierId,
                Users.UserId,
                AgenciesxUser.AgencyId
     FROM Cashiers
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
              INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
         WHERE AgenciesxUser.AgencyId = @AgencyId
               AND (Cashiers.CashierId <>
                   (
                       SELECT c2.CashierId
                       FROM Cashiers c2
                       WHERE UserId = @UserId
                   )
                    OR @UserId IS NULL) and Cashiers.IsActive = 1
         ORDER BY Users.Name;
     END;
GO