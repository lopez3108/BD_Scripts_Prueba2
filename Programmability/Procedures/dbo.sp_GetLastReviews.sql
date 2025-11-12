SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 21/10/2024 5:53 p. m.
-- Database:    developing
-- Description: task 6108 Revisar lógica de los review pending
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetLastReviews]
(@UserId      INT      = NULL, 
 @CurrentDate DATETIME
)
AS
    BEGIN

	SELECT
  *
 ,QueryFinal.Status StatusT
 ,CASE
    WHEN DATEDIFF(DAY, MaxCyclePermit, @CurrentDate) > 0  THEN 'required'
    ELSE ''
  END AS
  blocking
 ,CASE
    WHEN DATEDIFF(DAY, MaxCyclePermit, @CurrentDate) > 0 THEN 1
    ELSE 0
  END AS
  overdue
  ,(DATEDIFF(DAY,  @CurrentDate,MaxCyclePermit)) RealDiference
 ,ABS(DATEDIFF(DAY,  @CurrentDate,MaxCyclePermit)) resultado
FROM (SELECT TOP 20
    T.*
   ,
    --Consultamos el ciclo hasta lo máximo permitido, que sería el NextCycle mas la configuración de días a completar
    CASE
      WHEN D.Code = 'C01' THEN DATEADD(DAY, 9, DATEFROMPARTS(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(T.CycleDate)))
      WHEN D.Code = 'C02' THEN DATEADD(DAY, 19, DATEFROMPARTS(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(T.CycleDate)))
      ELSE 
	  --Para el caso de de 30 días, entonces ponemos como ultimo plazo, el último día del mes
	 CAST(DATEFROMPARTS(YEAR(T.NextCycle), MONTH(T.CycleDate), DAY(dateadd(month,1+datediff(month,0,T.NextCycle),-1))) AS date)
    END AS MaxCyclePermit

  FROM (
    --Reviews que fueron completados por el usuario
   SELECT
      rev.ReviewId,
      rev.ReviewName,
      rev.Status,
      rev.CycleDate,
      rev.DaysToCompleteStatusId,
      rev.DocumentName,
      rev.CreatedBy,
      rev.LastUpdatedOn,
      rev.LastUpdatedBy,
      revu.ReviewXUserId,
      revu.UserId,
      revu.AgencyId,
      revu.SignName,
      revu.LastCompleteOn,
      -- Consultamos el siguiente ciclo para el training que fue completado
      CASE
        WHEN MONTH(rev.CycleDate) > MONTH(revu.LastCompleteOn) THEN
          -- Cuando el mes del ciclo es mayor al mes del lastCompleted,
          -- el siguiente ciclo es en el mismo año del lastCompleted
          CAST(DATEFROMPARTS(YEAR(revu.LastCompleteOn), MONTH(rev.CycleDate), DAY(rev.CycleDate)) AS DATE)
        ELSE
          -- Si el mes del ciclo es menor o igual al mes del lastCompleted,
          -- el siguiente ciclo es en el año siguiente
          CAST(DATEFROMPARTS(YEAR(revu.LastCompleteOn) + 1, MONTH(rev.CycleDate), DAY(rev.CycleDate)) AS DATE)
      END AS NextCycle
FROM Reviews rev
INNER JOIN (
    SELECT revu_inner.*
    FROM ReviewXUsers revu_inner
    INNER JOIN (
        -- Subconsulta para obtener el último registro por UserId
        SELECT UserId, MAX(LastCompleteOn) AS LastCompleteOn
        FROM ReviewXUsers
        GROUP BY UserId
    ) revu_last ON revu_inner.UserId = revu_last.UserId
               AND revu_inner.LastCompleteOn = revu_last.LastCompleteOn
) revu ON rev.ReviewId = revu.ReviewId
WHERE 
    rev.Status = 2
    AND revu.UserId = @UserId


    UNION ALL

    SELECT
      rev.ReviewId
     ,rev.ReviewName
     ,rev.Status
     ,rev.CycleDate
     ,rev.DaysToCompleteStatusId
     ,rev.DocumentName
     ,rev.CreatedBy
     ,rev.LastUpdatedOn
     ,rev.LastUpdatedBy
     ,NULL ReviewXUserId
     ,NULL UserId
     ,NULL AgencyId
     ,NULL SIgnName
     ,NULL LastCompleteOn
     ,rev.CycleDate NextCycle-- Para los reviews que nunca han sido completados por el usuario, el siguiente ciclo es igual al ciclo inicial del review
    FROM Reviews rev
    WHERE NOT EXISTS (SELECT TOP 1
        1
      FROM ReviewXUsers revu
      WHERE 
	revu.ReviewId = rev.ReviewId
    AND revu.UserId = @UserId)
	--2 = Estado activo
    AND rev.Status = 2
	) AS T

  INNER JOIN ReviewDaysStatus D
    ON D.DaysToCompleteStatusId = T.DaysToCompleteStatusId) AS QueryFinal
WHERE (@CurrentDate >= CAST(DATEFROMPARTS(YEAR(QueryFinal.NextCycle), MONTH(QueryFinal.NextCycle), 1) AS DATE))
 END


   --     DECLARE @CurrentDateCycle DATE;
   --     SET @CurrentDateCycle = DATEFROMPARTS(YEAR(@CurrentDate), MONTH(@CurrentDate), 1);
   --     SELECT TOP 20 *,
   --                   CASE
   --                       WHEN D.Code = 'C01'
   --                       THEN DATEADD(DAY, 10, R.CycleDate)
   --                       WHEN D.Code = 'C02'
   --                       THEN DATEADD(DAY, 20, R.CycleDate)
   --                       ELSE DATEADD(DAY, 30, R.CycleDate)
   --                   END AS DateChance
   --     FROM dbo.Reviews R
   --          INNER JOIN ReviewDaysStatus D ON D.DaysToCompleteStatusId = R.DaysToCompleteStatusId
   --          LEFT JOIN ReviewXUsers Tu ON R.ReviewId = Tu.ReviewId  AND (TU.UserId = @UserId
   --                OR TU.UserId IS NULL)
   --     WHERE R.STATUS = 2
   --           AND R.ReviewId NOT IN
   --     (
   --         SELECT txu.ReviewId
   --         FROM ReviewXUsers txu
   --         WHERE((txu.UserId = @UserId
   --               AND YEAR(txu.LastCompleteOn) = YEAR(@CurrentDate))
   --               OR (txu.UserId = @UserId
   --                   AND YEAR(txu.LastCompleteOn) > YEAR(@CurrentDate)))
   --     )
   --           AND CAST(R.CycleDate AS DATE) <= @CurrentDateCycle      
            
			
			--AND EXISTS
   --     (
   --         SELECT ComplianceRol, 
   --                IsAdmin
   --         FROM Cashiers C
			--INNER JOIN RolCompliance R ON  R.RolComplianceId = C.ComplianceRol
   --         WHERE C.UserId = @UserId
   --               AND R.Code = 'C03'
   --               AND C.IsAdmin = 1
   --     )
   --     ORDER BY R.creationDate DESC;
   -- END;

GO