SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTraining] @Name       VARCHAR(150) = NULL,
                                       @TrainingId INT          = NULL
AS
     BEGIN
         SELECT 
                T.TrainingId,
                T.CreationDate,
				FORMAT(T.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
                T.TrainingName,
                T.Status,
                T.IsRequired,				
               CASE
                   WHEN T.IsRequired = 1
                   THEN 'SI'
                   ELSE 'NO'
               END AS [IsRequiredFormat],

                T.CycleDate,
                T.DocumentName,
				T.CreatedBy,
				T.LastUpdatedOn,
				FORMAT(T.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastUpdatedOnFormat,
                U.Name AS LastUpdatedByName,--Trainer name
				U.UserId AS LastUpdatedById,
                D.Description,
                D.DaysToCompleteStatusId,
				CAST( T.ApplyToAdmin AS BIT) AS ApplyToAdmin,
				CAST( T.ApplyToCashier AS BIT) AS ApplyToCashier,
				CAST( T.ApplyToManager AS BIT) AS ApplyToManager,
                CAST(T.CycleDate AS DATE) AS CycleDateFormat,
                CASE
                    WHEN D.Code = 'C01'
                    THEN DATEADD(DAY, 10, T.CycleDate)
                    WHEN D.Code = 'C02'
                    THEN DATEADD(DAY, 20, T.CycleDate)
                    ELSE DATEADD(DAY, 30, T.CycleDate)
                END AS DateChance,
                CASE
                    WHEN T.Status = '2'
                    THEN 'ACTIVE'
                    WHEN T.Status = '3'
                    THEN 'INACTIVE'
                END AS StatusTraining,
                T.DocumentName AS DocumentNameSaved,
                Uc.Name AS CreatedByName,
         (
             SELECT COUNT(Question)
             FROM TrainingQuestions
             WHERE TrainingId = T.TrainingId
         ) AS CountQuestiosns,
		 (SELECT Us.Name FROM Cashiers C INNER JOIN RolCompliance RC ON RC.RolComplianceId = C.ComplianceRol
		 INNER JOIN Users Us ON Us.UserId = c.UserId WHERE RC.Code = 'C02') ComplianceOfficerName,
		  (SELECT Us.UserId FROM Cashiers C INNER JOIN RolCompliance RC ON RC.RolComplianceId = C.ComplianceRol
		 INNER JOIN Users Us ON Us.UserId = c.UserId WHERE RC.Code = 'C02') ComplianceOfficerId
         FROM Training T
              INNER JOIN Users U ON U.UserId = T.LastUpdatedBy
              INNER JOIN Users Uc ON Uc.UserId = T.CreatedBy
	--iNNER JOIN TrainingAppliesTo TA ON T.TrainingId = TA.TrainingId
              INNER JOIN TrainingDaysStatus D ON D.DaysToCompleteStatusId = T.DaysToCompleteStatusId
         WHERE(T.TrainingName LIKE '%'+@Name+'%' 
               OR @Name IS NULL)
              AND (T.TrainingId = @TrainingId
                   OR @TrainingId IS NULL);
     END;
GO