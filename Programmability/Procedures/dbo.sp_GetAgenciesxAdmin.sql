SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 04/08/2025 task 6665   Nuevo campo MID serial number para los Agencies 

CREATE PROCEDURE [dbo].[sp_GetAgenciesxAdmin]
(
 @IsActive BIT         = NULL,
 @Name varchar(50) =NULL,
 @Code varchar(10) =NULL,
 @Telephone varchar(20) =NULL,
 @Address varchar(100) =NULL

)
AS
     BEGIN
         SELECT Agencies.AgencyId,
                Agencies.AdminId,
                UPPER(Agencies.Name) AS Name,
                UPPER(Agencies.Code) AS Code,
                UPPER(Agencies.Code+' - '+Agencies.Name) AgencyCodeName,
                UPPER(Agencies.Manager) AS Manager,
                Agencies.Telephone,
                Agencies.Telephone2,
                Agencies.Fax,
				Agencies.FlexxizCode,
                UPPER(Agencies.Email) AS Email,
                Agencies.ZipCode,
                UPPER(Agencies.Address) AS Address,
                UPPER(Agencies.Owner) AS Owner,
                UPPER(Agencies.IsActive) AS IsActive,
				   CASE
                   WHEN Agencies.IsActive = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
               END AS [IsActiveFormat],
                UPPER(ZipCodes.City) AS City,
                UPPER(ZipCodes.State)+CASE
                                          WHEN ZipCodes.StateAbre IS NULL
                                          THEN ''
                                          ELSE ' - '+UPPER(ZipCodes.StateAbre)
                                      END AS State,
                UPPER(ZipCodes.County) AS County,
                UPPER(Agencies.Mid) AS Mid,
                [InitialBalanceCash],
                FORMAT(LastInitialBalanceSaved, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastUpdatedInitialOnFormat,
                 FORMAT(AgencyLastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastUpdatedOnFormat,
                 FORMAT(AgencyCreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreatedOnFormat,
                 cast(LastInitialBalanceSaved AS DATETIME) LastInitialBalanceSaved,
                u.Name AS LastUpdatedInitialByName,
                uc.Name AS CreatedByName,
                ul.Name AS LastUpdatedByName,
                AgencyCreatedBy,
                AgencyLastUpdatedBy,
                LastInitialBalanceBy,
                  -- 🚀 Agregado: Primer MidNumber de la agencia
                 FirstMid.MidNumber AS FirstMidNumber
          




         FROM Agencies
              INNER JOIN ZipCodes ON Agencies.ZipCode = ZipCodes.ZipCode
              LEFT JOIN Users u ON U.UserId = Agencies.LastInitialBalanceBy
              LEFT JOIN Users uc ON uc.UserId = Agencies.AgencyCreatedBy
              LEFT JOIN Users ul ON Ul.UserId = Agencies.AgencyLastUpdatedBy

    -- ✅ OUTER APPLY en lugar de CROSS APPLY
        OUTER APPLY (
            SELECT TOP 1 MidNumber
            FROM MidSerialsByAgency m
            WHERE m.AgencyId = Agencies.AgencyId
            ORDER BY m.MidSerialsByAgencyId
        ) AS FirstMid

         WHERE(Agencies.IsActive = @IsActive
               OR @IsActive IS NULL) AND 
			   (Agencies.Name LIKE  '%'+@Name+'%'
               OR @Name IS NULL) AND 
			   (Agencies.Code LIKE  '%'+@Code+'%'
               OR @Code IS NULL) AND
			   (Agencies.Telephone LIKE  '%'+@Telephone+'%'
               OR @Telephone IS NULL) AND 
			   (Agencies.Address LIKE '%'+@Address+'%'
               OR @Address IS NULL)
         ORDER BY Agencies.Name;
     END;

GO