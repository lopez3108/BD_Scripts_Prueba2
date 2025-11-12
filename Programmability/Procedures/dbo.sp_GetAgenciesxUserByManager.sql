SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetAgenciesxUserByManager] (@UserId INT = NULL, @IsActive BIT = NULL,
@UserManagerId INT = NULL)
AS
BEGIN
  SELECT
    Agencies.AgencyId
   ,Agencies.Name
   ,Agencies.Name AgencyName
   ,Agencies.Address AgencyAddress
   ,REPLACE(Agencies.Telephone, ' ', '') AgencyPhone
   ,Agencies.Code
   ,Agencies.IsActive AS IsActive
   ,Agencies.Code + ' - ' + Agencies.Name AS CodeName
   ,AgenciesxUser.UserId
   ,ZipCodes.City AgencyCity
   ,CASE
      WHEN ZipCodes.StateAbre IS NULL THEN ' '
      ELSE ' ' + ZipCodes.StateAbre
    END AS AgencyStateAbreviation
   ,Agencies.ZipCode AgencyZipCode
   ,Agencies.FlexxizCode
  FROM Agencies
  LEFT JOIN AgenciesxUser
    ON CASE
        WHEN @UserId IS NOT NULL AND
          AgenciesxUser.UserId = @UserId THEN Agencies.AgencyId
        ELSE NULL
      END = AgenciesxUser.AgencyId
  LEFT JOIN ZipCodes
    ON Agencies.ZipCode = ZipCodes.ZipCode
  WHERE (Agencies.IsActive = @IsActive
  OR @IsActive IS NULL)
  AND (@UserId IS NOT NULL
  AND AgenciesxUser.UserId IS NOT NULL
  OR @UserId IS NULL)
  AND (Agencies.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
END;

GO