SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-23 JF/5817: Inactive cashiers should continue to appear on the different payroll lists

CREATE PROCEDURE [dbo].[sp_GetCashiersActivesAndInactivesXAgencyId] @AgencyId INT = NULL, 
                                                @IsActive BIT = NULL
AS
    BEGIN
        SELECT DISTINCT
               Users.Name, 
               Users.UserId 
         
     FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
        WHERE(AgenciesxUser.AgencyId = @AgencyId
              OR @AgencyId IS NULL)
             AND (Cashiers.IsActive = @IsActive
                  OR Users.UserId IN (SELECT bth.UserId FROM BreakTimeHistory bth))
        ORDER By Users.Name ASC;
    END;
GO