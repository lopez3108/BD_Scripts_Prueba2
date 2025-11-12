SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/12-09-2024  El sistema no está permitiendo eliminar usuarios de un grupo
-- =============================================
-- Author:      sa
-- Create date: 23/08/2024 9:43 p. m.
-- Database:    [copySecure12-08-2024]
-- Description: task 5996El sistema no está permitiendo eliminar usuarios de un grupo
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetAllChatGroup] @Name VARCHAR(100) = NULL,
@AgencyId INT = NULL, @GroupId INT = NULL
AS
BEGIN
  -- Si @GroupId es NULL, no se hace JOIN con la tabla UsersXGroup
  IF @GroupId IS NULL
  BEGIN
    SELECT DISTINCT
      NULL AS UserXGroupId
     ,NULL AS GroupId
     ,u.Name AS Name
     ,u.UserId
     ,u.[user] AS Email
     ,STUFF((SELECT DISTINCT
          ', ' + a.Code
        FROM AgenciesxUser au
        INNER JOIN Agencies a
          ON au.AgencyId = a.AgencyId
        WHERE u.[UserId] = au.[UserId]
        FOR XML PATH (''), TYPE)
      .value('.', 'NVARCHAR(MAX)'), 1, 2, ''
      ) AS Agenciesss
    FROM [Users] u
    INNER JOIN Cashiers
      ON u.UserId = Cashiers.UserId
    LEFT JOIN AgenciesxUser au
      ON au.UserId = u.UserId
    LEFT JOIN Agencies a
      ON au.AgencyId = a.AgencyId
    WHERE ((u.Name LIKE '%' + @Name + '%'
    OR u.[User] LIKE '%' + @Name + '%'
    OR @Name IS NULL
    OR @Name = ''))
    AND (a.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND (Cashiers.IsActive = 1)
    ORDER BY u.Name

  END
  ELSE
  BEGIN
    -- Si @GroupId no es NULL, se hace JOIN con la tabla UsersXGroup
    SELECT DISTINCT
      ux.UserXGroupId
     ,ux.GroupId
     ,u.Name AS Name
     ,u.UserId
     ,u.[user] AS Email
     ,uA.Name AS AddedByName
     ,FORMAT(ux.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
     ,STUFF((SELECT DISTINCT
          ', ' + a.Code
        FROM AgenciesxUser au
        INNER JOIN Agencies a
          ON au.AgencyId = a.AgencyId
        WHERE u.[UserId] = au.[UserId]
        FOR XML PATH (''), TYPE)
      .value('.', 'NVARCHAR(MAX)'), 1, 2, ''
      ) AS Agenciesss
    FROM [Users] u
    INNER JOIN Cashiers
      ON u.UserId = Cashiers.UserId
    LEFT JOIN AgenciesxUser au
      ON au.UserId = u.UserId
    LEFT JOIN Agencies a
      ON au.AgencyId = a.AgencyId
    LEFT JOIN UsersXGroup ux
      ON u.UserId = ux.UserId
        AND ux.GroupId = @GroupId
    LEFT JOIN [Users] uA
      ON ux.CreatedBy = uA.UserId
    WHERE ((u.Name LIKE '%' + @Name + '%'
    OR u.[User] LIKE '%' + @Name + '%'
    OR @Name IS NULL
    OR @Name = ''))
    AND (a.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND (Cashiers.IsActive = 1)
    ORDER BY u.Name

  END
END;


GO