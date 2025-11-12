SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetRecordTrainings] @FromDate     DATE         = NULL, 
                                              @ToDate       DATE         = NULL, 
                                              @AgencyId     INT          = NULL, 
                                              @TrainingName VARCHAR(150) = NULL
AS
    BEGIN
        SELECT TX.LastCompleteOn AS Date, 
		FORMAT(TX.LastCompleteOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  DateFormat,
               T.TrainingId, 
               TX.TrainingXUserId, 
               TX.UserId, 
               tx.AgencyId, 
               t.TrainingName, 
               UPPER(a.Code + ' - ' + a.Name) Agency, 
               UPPER(dbo.Users.Name) AS EmployeeName ,
               US.Name AS TrainerName
--        (
--            SELECT UPPER(dbo.Users.Name)
--            FROM Training TR
--                 INNER JOIN dbo.Users ON dbo.Users.UserId = TR.LastUpdatedBy                 
--            WHERE code = 'C02'
--        ) TrainerName
        FROM TrainingXUsers TX
             INNER JOIN Training T ON T.TrainingId = TX.TrainingId             
             INNER JOIN Agencies a ON a.AgencyId = tx.AgencyId
             INNER JOIN dbo.Users ON dbo.Users.UserId = tx.UserId
             INNER JOIN dbo.Users US ON US.UserId = TX.TrainerId 
             
        WHERE(TX.AgencyId = @AgencyId
              OR @AgencyId IS NULL)
             AND (T.TrainingName LIKE '%' + @TrainingName + '%'
                  OR @TrainingName IS NULL)
             AND ((CAST(TX.LastCompleteOn AS DATE) >= CAST(@FromDate AS DATE)
                   OR @FromDate IS NULL)
                  AND (CAST(TX.LastCompleteOn AS DATE) <= CAST(@ToDate AS DATE))
                  OR @ToDate IS NULL)
        ORDER BY TX.LastCompleteOn DESC;
    END;

GO