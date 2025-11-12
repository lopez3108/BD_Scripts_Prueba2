SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAgenciesxUser](@UserId INT = NULL, @IsActive BIT = NULL)
AS
     BEGIN
        SELECT  Agencies.AgencyId,
                Agencies.Name,
                Agencies.Name AgencyName,
                Agencies.Address AgencyAddress,
                replace(Agencies.Telephone, ' ', '') AgencyPhone,
                Agencies.Code,
				Agencies.IsActive AS IsActive,
                Agencies.Code+' - '+Agencies.Name AS CodeName,
                AgenciesxUser.UserId,
                ZipCodes.City AgencyCity,
                CASE
                    WHEN ZipCodes.StateAbre IS NULL
                    THEN ' '
                    ELSE ' '+ZipCodes.StateAbre
                END AS AgencyStateAbreviation,
                Agencies.ZipCode AgencyZipCode,
				Agencies.FlexxizCode
         FROM Agencies 
              LEFT JOIN AgenciesxUser ON CASE WHEN @UserId IS NOT NULL AND AgenciesxUser.UserId = @UserId THEN  Agencies.AgencyId 
			  ELSE NULL END  = AgenciesxUser.AgencyId
              LEFT JOIN ZipCodes ON Agencies.ZipCode = ZipCodes.ZipCode
			   WHERE (Agencies.IsActive =@IsActive OR @IsActive IS NULL) AND (@UserId IS NOT NULL AND AgenciesxUser.UserId IS NOT NULL OR @UserId IS NULL)
     END;
GO