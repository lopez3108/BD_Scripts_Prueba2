SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberTrainingWithoutRead]
(@UserId AS      INT, 
 @CurrentDate DATETIME, 
 @Rol         VARCHAR(10)
)
AS
    BEGIN
        DECLARE @CurrentDateCycle DATE;
        SET @CurrentDateCycle = DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), 1);
        SELECT COUNT(*) TrainingCount
        FROM dbo.Training t
             LEFT JOIN TrainingXUsers Tu ON T.TrainingId = Tu.TrainingId
                                            AND (TU.UserId = @UserId
                                                 OR TU.UserId IS NULL)
        WHERE T.STATUS = 2
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
              AND (TU.UserId = @UserId
                   OR TU.UserId IS NULL)
              AND ((T.ApplyToCashier = 1
                   AND @Rol = 'Cashier')
              OR (T.ApplyToAdmin = 1
                  AND @Rol = 'Admin')
              OR (T.ApplyToManager = 1
                  AND @Rol = 'Manager'));
    END;
GO