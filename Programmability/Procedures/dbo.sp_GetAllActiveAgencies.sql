SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllActiveAgencies]
AS
     BEGIN
         SELECT Agencies.Code+' - '+Agencies.Name AS CodeName,
                Agencies.AgencyId,
                Agencies.AdminId,
                Agencies.Name,
                Agencies.Code,
                Agencies.Manager,
                Agencies.Telephone,
                Agencies.Telephone2,
                Agencies.Fax,
                Agencies.Email,
                Agencies.ZipCode,
                Agencies.Address,
                Agencies.Owner,
                Agencies.IsActive,
                ZipCodes.City,
                ZipCodes.State+CASE
                                   WHEN ZipCodes.StateAbre IS NULL
                                   THEN ''
                                   ELSE ' - '+ZipCodes.StateAbre
                               END AS State,
                ZipCodes.County,
                Agencies.IsActive
         FROM Agencies
              INNER JOIN ZipCodes ON Agencies.ZipCode = ZipCodes.ZipCode
         WHERE Agencies.IsActive = 1
         ORDER BY Agencies.Name;
     END;
GO