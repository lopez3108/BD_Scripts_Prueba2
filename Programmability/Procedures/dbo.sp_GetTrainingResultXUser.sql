SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetTrainingResultXUser] @UserId     INT,
                                                  @TrainingId INT,
                                                  @AgencyId   INT
AS
     BEGIN
         SELECT TX.TrainingId,
                TX.UserId,
                t.TrainingName,
                UT.Name AS TrainerName,             
                TX.LastCompleteOn,
                TX.AgencyId,
                TX.UserId AS CompletedBy,
                U.[User] AS Email,
                U.Name AS EmployeeName,
                a.code+' - '+a.Name AgencyName,
                a.TelePhone AgencyPhone,
                a.Address+ ' ' + ZipCodes.City+CASE
                                            WHEN ZipCodes.StateAbre IS NULL
                                            THEN ''
                                            ELSE ', '+UPPER(ZipCodes.StateAbre)
                                        END AS AgencyAddress,
                tx.TrainingXUserId,
				(
            SELECT UPPER(dbo.Users.Name)
            FROM Cashiers c
                 INNER JOIN dbo.Users ON dbo.Users.UserId = c.UserId
                 INNER JOIN RolCompliance r ON r.RolComplianceId = c.ComplianceRol
            WHERE code = 'C02'
        ) ComplianceOfficerName
         FROM Training t
              INNER JOIN TrainingXUsers TX ON T.TrainingId = tx.TrainingId
              LEFT JOIN Agencies A ON A.AgencyId = @AgencyId
              INNER JOIN ZipCodes ON A.ZipCode = ZipCodes.ZipCode
              INNER JOIN Users U ON U.UserId = TX.UserId
              INNER JOIN Users UT ON UT.UserId = T.LastUpdatedBy
			         


         WHERE(TX.UserId = @UserId
               AND t.TrainingId = @TrainingId);
     END;

	 SELECT  * FROM Cashiers
GO