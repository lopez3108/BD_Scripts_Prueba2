SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllUsersXAgencyId] @AgencyId INT = NULL
AS
    BEGIN
        SELECT DISTINCT 
               Users.Name, 
               Users.UserId
        --AgenciesxUser.AgencyId
        FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
             LEFT JOIN Admin ON Admin.UserId = Users.UserId
        WHERE(AgenciesxUser.AgencyId = @AgencyId
              OR @AgencyId IS NULL)
             AND IsActive = 1
        UNION
        SELECT Users.Name, 
               Users.UserId
        FROM Admin
             INNER JOIN Users ON Admin.UserId = Users.UserId
        ORDER BY Users.Name;
    END;


GO