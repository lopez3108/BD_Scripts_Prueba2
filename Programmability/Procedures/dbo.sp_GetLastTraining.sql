SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by jt 15-05-2024 / task 5851 Training-  dar plazo para presentar a cajeros nuevos
CREATE PROCEDURE [dbo].[sp_GetLastTraining] (@UserId INT = NULL,
@CurrentDate DATETIME,
@Rol VARCHAR(10))
AS
BEGIN
  DECLARE @StartDateUser AS DATE;
  SET @StartDateUser = (SELECT
      u.UserCreatedOn
    FROM Users u
    INNER JOIN Cashiers c
      ON u.UserId = c.UserId
    WHERE c.UserId = @UserId)
  SELECT
    *
    --,QueryFinal.Status StatusT
   ,CASE
      WHEN DATEDIFF(DAY, MaxCyclePermit, @CurrentDate) > 0 AND
        IsRequired = 1 THEN 'required'
      ELSE ''
    END AS
    blocking
   ,CASE
      WHEN DATEDIFF(DAY, MaxCyclePermit, @CurrentDate) > 0 THEN 1
      ELSE 0
    END AS
    overdue
   ,(DATEDIFF(DAY, @CurrentDate, MaxCyclePermit)) RealDiference
   ,ABS(DATEDIFF(DAY, @CurrentDate, MaxCyclePermit)) resultado
  FROM (SELECT TOP 20
      T.*
     ,
      --Consultamos el ciclo hasta lo máximo permitido, que sería el NextCycle mas la configuración de días a completar
      CASE
        WHEN D.Code = 'C01' THEN DATEADD(DAY, 9, datefromparts(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(T.CycleDate)))
        WHEN D.Code = 'C02' THEN DATEADD(DAY, 19, datefromparts(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(T.CycleDate)))
        -- ELSE               CAST(datefromparts(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, T.NextCycle), -1))) AS DATE)

        ELSE CASE
            WHEN LastCompleteOn IS NOT NULL THEN -- Para el caso de 30 días y que el training se haya completado antes, entonces ponemos como último plazo, el último día del mes
              CAST(datefromparts(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, T.NextCycle), -1))) AS DATE)
            ELSE -- Para el caso de 30 días y que no haya completado nunca el training, entonces se le dan los 30 días de plazo
              DATEADD(DAY, 29, datefromparts(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(T.CycleDate)))
          END
      END AS MaxCyclePermit

    FROM (
      --Trainings que fueron completados por el usuario
      SELECT
        tra.TrainingId
       ,tra.TrainingName
       ,tra.Status
       ,tra.IsRequired
       ,tra.CycleDate
       ,tra.DaysToCompleteStatusId
       ,tra.DocumentName
       ,tra.CreatedBy
       ,tra.LastUpdatedOn
       ,tra.LastUpdatedBy
       ,tra.ApplyToAdmin
       ,tra.ApplyToCashier
       ,tra.ApplyToManager
       ,txu.TrainingXUserId
       ,txu.UserId
       ,txu.AgencyId
       ,txu.SIgnName
       ,txu.LastCompleteOn
       ,
        --Consultamos el siguiente ciclo para el training que fue completado
        CASE

          WHEN CAST(tra.CycleDate AS DATE) > CAST(txu.LastCompleteOn AS DATE) THEN CAST(tra.CycleDate AS DATE) -- It was commented by the task 5856

          --Cuando la fecha del ciclo es mayor a la fecha del utlimo traning o sea LastCompleteOn entonces , la fecha del sigueinte ciclo es igual a la fecha del ciclo que tiene configurado el traning 
          WHEN MONTH(tra.CycleDate) > MONTH(txu.LastCompleteOn) THEN
            --Cuando el mes del ciclo iniical es mayor > que el mes del lastCompleted, 
            --entonces el año del Siguiente ciclo es el mismo año que el del las completed, , mes del cicloInicial y día del ciclocicloInicial
            CAST(datefromparts(YEAR(txu.LastCompleteOn), MONTH(tra.CycleDate), DAY(tra.CycleDate)) AS DATE)
          ELSE
            --Cuando el mes del ciclo inicial es menor o igual <= al mes del las completed, 
            --entonces el año del siguiente ciclo es igual al año del lastCompleted más 1 año, mes del cicloInicial y día del cicloInicial
            CAST(datefromparts(YEAR(txu.LastCompleteOn) + 1, MONTH(tra.CycleDate), DAY(tra.CycleDate)) AS DATE)
        END
        AS NextCycle

      FROM Training tra--Related with tbl TrainingXUsers by the last completedon date
      INNER JOIN (SELECT
          TrainingId
         ,MAX(LastCompleteOn) AS LastCompleteOn
        FROM TrainingXUsers
        WHERE UserId = @UserId
        GROUP BY TrainingId) txu_max
        ON tra.TrainingId = txu_max.TrainingId
      INNER JOIN TrainingXUsers txu
        ON tra.TrainingId = txu.TrainingId
        AND txu_max.LastCompleteOn = txu.LastCompleteOn
      WHERE
      --2 = Estado activo
      tra.Status = 2
      AND (txu.UserId = @UserId)
      AND ((tra.ApplyToCashier = 1
      AND @Rol = 'Cashier')
      OR (tra.ApplyToAdmin = 1
      AND @Rol = 'Admin')
      OR (tra.ApplyToManager = 1
      AND @Rol = 'Manager'))
      UNION ALL

      SELECT--Trainins que nunca han sido completados por el user
        tra.TrainingId
       ,tra.TrainingName
       ,tra.Status
       ,tra.IsRequired
       ,CASE
          WHEN CAST(tra.CycleDate AS DATE) > (@StartDateUser) THEN
            --1) Si la fecha inicio es mayor a la fecha de creación del cajero, entonces el ciclo es la fecha de inico del training
            CAST(tra.CycleDate AS DATE)
          --2) Si el ciclo es menor o igual a lfecha de de creación del user , entonces la fecha del siuignete ciclo es la fecha de inicio del user task 5851

          ELSE @StartDateUser
        END
        CycleDate
       ,tra.DaysToCompleteStatusId
       ,tra.DocumentName
       ,tra.CreatedBy
       ,tra.LastUpdatedOn
       ,tra.LastUpdatedBy
       ,tra.ApplyToAdmin
       ,tra.ApplyToCashier
       ,tra.ApplyToManager
       ,NULL TrainingXUserId
       ,NULL UserId
       ,NULL AgencyId
       ,NULL SIgnName
       ,NULL LastCompleteOn
        --,tra.CycleDate NextCycle-- Para los trainigs que nunca han sido completados por el usuario, el siguiente ciclo es igual al ciclo inicial del training, 

        --Para los trainigs que nunca han sido completados por el usuario, el siguiente ciclo es igual a:
       ,CASE
          WHEN CAST(tra.CycleDate AS DATE) > (@StartDateUser) THEN
            --1) Si la fecha inicio es mayor a la fecha de creación del cajero, entonces el ciclo es la fecha de inico del training
            CAST(tra.CycleDate AS DATE)
          --2) Si el ciclo es menor o igual a lfecha de de creación del user , entonces la fecha del siuignete ciclo es la fecha de inicio del user task 5851

          ELSE @StartDateUser
        END NextCycle
      --        CAST(datefromparts(YEAR(@StartDateUser), MONTH(@StartDateUser), DAY(@StartDateUser)) AS DATE) NextCycle
      FROM Training tra
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM TrainingXUsers trau
        WHERE trau.TrainingId = tra.TrainingId
        AND trau.UserId = @UserId)
      --2 = Estado activo
      AND tra.Status = 2
      AND ((tra.ApplyToCashier = 1
      AND @Rol = 'Cashier')
      OR (tra.ApplyToAdmin = 1
      AND @Rol = 'Admin')
      OR (tra.ApplyToManager = 1
      AND @Rol = 'Manager'))) AS T

    INNER JOIN TrainingDaysStatus D
      ON D.DaysToCompleteStatusId = T.DaysToCompleteStatusId) AS QueryFinal
  WHERE (@CurrentDate >= CAST(datefromparts(YEAR(QueryFinal.NextCycle), MONTH(QueryFinal.NextCycle), 1) AS DATE))
END



GO