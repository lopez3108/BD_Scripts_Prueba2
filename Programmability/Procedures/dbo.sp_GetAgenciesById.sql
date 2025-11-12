SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAgenciesById](@AgencyId VARCHAR(50))
AS
     BEGIN
         SELECT Agencies.AgencyId,
                Agencies.AdminId,
                Agencies.Name,
                Agencies.Code,
                Agencies.Manager,
                Agencies.Telephone,
                Agencies.Telephone2,
                replace(Agencies.Telephone, ' ', '') AgencyPhone,
                Agencies.Code+' - '+Agencies.Name AS CodeName,
                Agencies.Fax,
                Agencies.Email,
                Agencies.ZipCode,
                Agencies.Address,
                Agencies.Owner,
                Agencies.IsActive,
				        Agencies.FlexxizCode,
                ZipCodes.City,
                ZipCodes.State+CASE
                                   WHEN ZipCodes.StateAbre IS NULL
                                   THEN ''
                                   ELSE ' - '+ZipCodes.StateAbre
                               END AS State,
                --CASE
                --    WHEN ZipCodes.StateAbre IS NULL
                --    THEN ' '
                --    ELSE ' '+ZipCodes.StateAbre
                --END AS AgencyStateAbreviation,

                CASE
                    WHEN ZipCodes.StateAbre IS NULL
                    THEN ' '
                    ELSE ' '+ZipCodes.StateAbre
                END AS AgencyStateAbreviation,
                ZipCodes.County,
                Mid AS Mid,
                ZipCodes.StateAbre AS StateAbreviation,
                [InitialBalanceCash],
                cast(LastInitialBalanceSaved AS DATETIME) LastInitialBalanceSaved,
                u.Name AS LastUpdatedInitialByName,
                AgencyCreatedBy,
                AgencyLastUpdatedBy,
                cast(AgencyCreatedOn AS DATETIME) AgencyCreatedOn,
                cast(AgencyLastUpdatedOn AS DATETIME) AgencyLastUpdatedOn,
                [InitialBalanceCash] AS InitialBalanceCashSaved,
                LastInitialBalanceBy
         FROM Agencies
              INNER JOIN ZipCodes ON Agencies.ZipCode = ZipCodes.ZipCode
              LEFT JOIN Users u ON U.UserId = Agencies.LastInitialBalanceBy
             

         WHERE Agencies.AgencyId = @AgencyId;
     END;

GO