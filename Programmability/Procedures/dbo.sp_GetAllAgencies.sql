SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/20-06-2025 TASK 6618 Filter agencies by manager
CREATE PROCEDURE [dbo].[sp_GetAllAgencies]
@IsActive BIT = NULL,
@UserId INT = NULL
AS

     BEGIN IF @UserId IS NOT NULL
BEGIN
    SELECT
      Agencies.Code + ' - ' + Agencies.Name AS CodeName,
      Agencies.AgencyId,
      Agencies.AdminId,
      Agencies.Name,
      Agencies.Code,
      RIGHT(Agencies.Mid, 6) AS Mid,
      Agencies.Manager,
      REPLACE(Agencies.Telephone, ' ', '') AS Telephone,
      Agencies.Telephone2,
      Agencies.Fax,
      Agencies.Email,
      Agencies.ZipCode,
      Agencies.Address,
      Agencies.Owner,
      Agencies.IsActive,
      ZipCodes.City,
      ZipCodes.State +
        CASE
          WHEN ZipCodes.StateAbre IS NULL THEN ''
          ELSE ' - ' + ZipCodes.StateAbre
        END AS State,
      ZipCodes.County,
      Agencies.IsActive,
      ZipCodes.StateAbre
    FROM Agencies
    INNER JOIN ZipCodes ON Agencies.ZipCode = ZipCodes.ZipCode
    INNER JOIN AgenciesxUser AU ON AU.AgencyId = Agencies.AgencyId
    WHERE
      (Agencies.IsActive = @IsActive OR @IsActive IS NULL)
      AND AU.UserId = @UserId
    ORDER BY Agencies.Name;
END
ELSE
BEGIN
    SELECT
      Agencies.Code + ' - ' + Agencies.Name AS CodeName,
      Agencies.AgencyId,
      Agencies.AdminId,
      Agencies.Name,
      Agencies.Code,
      RIGHT(Agencies.Mid, 6) AS Mid,
      Agencies.Manager,
      REPLACE(Agencies.Telephone, ' ', '') AS Telephone,
      Agencies.Telephone2,
      Agencies.Fax,
      Agencies.Email,
      Agencies.ZipCode,
      Agencies.Address,
      Agencies.Owner,
      Agencies.IsActive,
      ZipCodes.City,
      ZipCodes.State +
        CASE
          WHEN ZipCodes.StateAbre IS NULL THEN ''
          ELSE ' - ' + ZipCodes.StateAbre
        END AS State,
      ZipCodes.County,
      Agencies.IsActive,
      ZipCodes.StateAbre
    FROM Agencies
    INNER JOIN ZipCodes ON Agencies.ZipCode = ZipCodes.ZipCode
    WHERE
      (Agencies.IsActive = @IsActive OR @IsActive IS NULL)
    ORDER BY Agencies.Name;
END

END;
GO