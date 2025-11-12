SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCashiersActives]
AS
BEGIN
  SELECT
    Users.Name
   ,Cashiers.CashierId
   ,Cashiers.IsActive
   ,Users.UserId
   ,Users.StartingDate
   ,CASE
      WHEN (SELECT
            [dbo].[CalculateVacations](Cashiers.UserId, Cashiers.CycleDateVacation, NULL))
        < 0 THEN 0
      ELSE (SELECT
            [dbo].[CalculateVacations](Cashiers.UserId, Cashiers.CycleDateVacation, NULL))
    END AS VacationHours
   ,
    --(select [dbo].[CalculateVacations](Cashiers.UserId)) AS VacationHours,
    Users.SocialSecurity
   ,Users.PaymentType
   ,Users.USD
   ,Users.BirthDay
  FROM Cashiers
  INNER JOIN Users
    ON Cashiers.UserId = Users.UserId
  WHERE Cashiers.IsActive = 1
  ORDER BY Users.Name;
END;

GO