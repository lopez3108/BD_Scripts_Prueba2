SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllUsersXAgencyList] @AgencyId VARCHAR(500) = NULL
AS
    BEGIN
        SELECT DISTINCT 
               Users.Name, 
               Users.UserId
        FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
             LEFT JOIN Admin ON Admin.UserId = Users.UserId
        WHERE(AgenciesxUser.AgencyId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@AgencyId)
        )
        OR (@AgencyId = ''
            OR @AgencyId IS NULL))
             AND IsActive = 1
        ORDER BY Users.Name;
    END;
GO