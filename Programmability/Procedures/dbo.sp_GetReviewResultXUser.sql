SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReviewResultXUser] @UserId   INT,
                                                @ReviewId INT,
                                                @AgencyId INT
AS
     BEGIN
         SELECT r.ReviewId,
                ru.UserId,
                r.ReviewName,
                ru.LastCompleteOn,
                ru.AgencyId,
                ru.UserId AS AuditorId,
                U.Name AS Auditor,
                U.Name AS TheInterviewedPerson,
                u1.Name AS NameUpdated,
               
         (
             SELECT uo.Name
             FROM Cashiers C
                  INNER JOIN Users uo ON uo.UserId = C.UserId
                  INNER JOIN RolCompliance r ON r.RolComplianceId = C.ComplianceRol
             WHERE r.Code = 'C02'
                   AND IsAdmin = 1
         ) ComplianceOfficer,
                a.code+' - '+a.Name AgencyName,
                a.TelePhone AgencyPhone,
                a.Address+' '+ZipCodes.City+CASE
                                                WHEN ZipCodes.StateAbre IS NULL
                                                THEN ''
                                                ELSE ', '+UPPER(ZipCodes.StateAbre)
                                            END AS AgencyAddress,
                ru.ReviewXUserId
         FROM Reviews r
              INNER JOIN ReviewXUsers ru ON r.ReviewId = ru.ReviewId
              INNER JOIN Agencies A ON A.AgencyId = @AgencyId
              INNER JOIN ZipCodes ON A.ZipCode = ZipCodes.ZipCode
              INNER JOIN Users U ON U.UserId = ru.UserId
              INNER JOIN Users u1 ON u1.UserId = r.LastUpdatedBy
         WHERE(ru.UserId = @UserId
               AND r.ReviewId = @ReviewId);
     END;

GO