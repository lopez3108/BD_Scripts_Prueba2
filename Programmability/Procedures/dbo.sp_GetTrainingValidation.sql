SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTrainingValidation] @UserId      INT         = NULL, 
                                                 @CurrentDate DATETIME, 
                                                 @Rol         VARCHAR(10)
AS
    BEGIN
        --DECLARE @IsManager AS BIT, @IsAdmin AS BIT;
        --SELECT @IsManager = CAST(c.IsManager AS BIT), 
        --       @IsAdmin = CAST(c.IsAdmin AS BIT)
        --FROM Cashiers C
        --     INNER JOIN Users U ON U.UserId = C.UserId
      --  WHERE U.UserId = @UserId;
        DECLARE @CurrentDateCycle DATE;
        SET @CurrentDateCycle = DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), 1);
        DECLARE @Date AS DATE;
        SET @Date = GETDATE();
        SELECT *
        FROM
        (
            SELECT *, 
                   DATEDIFF(DAY, Query1.DateChance, @Date) Direfence
            FROM
            (
                SELECT T.TrainingId, 
                       T.CreationDate, 
                       T.TrainingName, 
                       T.STATUS, 
                       T.IsRequired, 
                       T.CycleDate, 
                       T.DocumentName, 
                       U.Name AS LastUpdatedByName, 
                       D.Description, 
                       D.DaysToCompleteStatusId, 
                       CAST(T.CycleDate AS DATE) AS CycleDateFormat,
                       CASE
                           WHEN D.Code = 'C01'
                           THEN DATEADD(DAY, 10, T.CycleDate)
                           WHEN D.Code = 'C02'
                           THEN DATEADD(DAY, 20, T.CycleDate)
                           ELSE DATEADD(DAY, 30, T.CycleDate)
                       END AS DateChance,
                       CASE
                           WHEN T.STATUS = '2'
                           THEN 'ACTIVE'
                           WHEN T.STATUS = '3'
                           THEN 'INACTIVE'
                       END AS StatusTraining, 
                       CAST(CASE
                                WHEN T.STATUS = '2'
                                THEN 1
                                WHEN T.STATUS = '3'
                                THEN 0
                            END AS BIT) AS StatusT, 
                       T.ApplyToCashier, 
                       T.ApplyToAdmin, 
                       T.ApplyToManager
                FROM Training T
                     INNER JOIN Users U ON U.UserId = T.LastUpdatedBy
                     INNER JOIN Users Uc ON Uc.UserId = T.CreatedBy
                     INNER JOIN TrainingDaysStatus D ON D.DaysToCompleteStatusId = T.DaysToCompleteStatusId
                     LEFT JOIN TrainingXUsers Tu ON T.TrainingId = Tu.TrainingId
                                                    AND (TU.UserId = @UserId
                                                         OR TU.UserId IS NULL)
                WHERE T.IsRequired = 1
                      AND t.TrainingId NOT IN
                (
                    SELECT txu.TrainingId
                    FROM TrainingXUsers txu
                    WHERE((txu.UserId = @UserId
                           AND YEAR(txu.LastCompleteOn) = YEAR(@CurrentDate))
                          OR (txu.UserId = @UserId
                              AND YEAR(txu.LastCompleteOn) > YEAR(@CurrentDate)))
                )
                      AND CAST(t.CycleDate AS DATE) <= @CurrentDateCycle

                      --AND  NOT EXISTS
                      --            (
                      --                SELECT trainingxuserid
                      --                FROM TrainingXUsers tu
                      --                WHERE tu.UserId = @UserId
                      --                      AND TU.TrainingId = t.TrainingId
                      --            )
                      --AND ((T.ApplyToCashier = 1 
                      --      OR (T.ApplyToAdmin = 1
                      --          AND @IsAdmin = 1)
                      --      OR (T.ApplyToManager = 1
                      --          AND @IsManager = 1)))

					  AND ((T.ApplyToCashier = 1 AND @Rol = 'Cashier') OR (T.ApplyToAdmin = 1 AND @Rol = 'Admin') OR (T.ApplyToManager = 1 AND @Rol = 'Manager'))
            ) AS Query1
        ) AS Query2
        WHERE Query2.Direfence >= 0;
    END;
GO