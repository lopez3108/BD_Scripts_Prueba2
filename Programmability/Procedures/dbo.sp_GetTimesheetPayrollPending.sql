SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--UpdatedBy JF, UpdatedON 21-Mayo-2024 , task 5819

CREATE PROCEDURE [dbo].[sp_GetTimesheetPayrollPending]
                 @CashierId varchar(500) = NULL, @DateFrom datetime = NULL, @DateTo datetime = NULL, @StatusCode varchar(4) = NULL, @UserId int = NULL
AS
  DECLARE @ListAgencyId AS nchar(1000);--Se busca solo las agencias cuando es MANAGER y sabemos que es MANAGER cuando trae un valor en el 
  -- @UserId de lo contrario sería ADMIN
  SET @ListAgencyId = (SELECT STRING_AGG(AgencyId, ',')
FROM AgenciesxUser aus
WHERE aus.UserId = @UserId);



  BEGIN

    SELECT *,
    CASE
         WHEN ExitTimeExceded <= 0 OR
              StatusId = 2 THEN 'APPROVED'
         ELSE 'PENDING'
    END AS STATUS,
    --       RIGHT('0' + CAST(FLOOR(COALESCE(HoursWorked * 60, 0) / 60) AS VARCHAR(8)), 2) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(HoursWorked * 60, 0) % 60) AS VARCHAR(2)), 2) + ':' + RIGHT('0' + CAST(FLOOR((
    --(
    --    SELECT dbo.fn_GetNumberRoundUp(HoursWorked) * 60
    --) * 60) % 60) AS VARCHAR(2)), 2) HoursWorkedFormatTime, 
    RIGHT('0' + CAST(FLOOR(COALESCE(ABS(ExitTimeExceded) * 60, 0) / 60) AS varchar(8)), 2) + ':' + RIGHT('0' + CAST(FLOOR(COALESCE(ABS(ExitTimeExceded) * 60, 0) % 60) AS varchar(2)), 2) + ':' + RIGHT('0' + CAST(FLOOR(((SELECT dbo.fn_GetNumberRoundUp(ABS(ExitTimeExceded)) * 60) * 60) % 60) AS varchar(2)), 2) ExitTimeExcededFormatTime
    FROM (SELECT CAST(ISNULL(DATEDIFF(SECOND, DATEDIFF(dd, 0, LogoutDate) + CONVERT(datetime, EstimatedDepartureTime), LogoutDate) / 3600.0, 0) AS decimal(18, 4)) ExitTimeExceded, ts.Code AS StatusCode, dbo.TimeSheet.StatusId,dbo.TimeSheet.TimeSheetId, Users.UserId, dbo.Agencies.AgencyId, LoginDate, LogoutDate
  FROM dbo.TimeSheet
       INNER JOIN  dbo.Users    ON dbo.TimeSheet.UserId = dbo.Users.UserId
       INNER JOIN  UserTypes ut ON Rol = ut.UsertTypeId
       INNER JOIN  dbo.Cashiers ON dbo.Users.UserId = dbo.Cashiers.UserId
       LEFT JOIN   dbo.TimeSheetStatus ts ON ts.Id = dbo.TimeSheet.StatusId
       LEFT JOIN   dbo.Agencies ON dbo.TimeSheet.AgencyId = dbo.Agencies.AgencyId
  WHERE (Cashiers.CashierId IN (SELECT item
      FROM dbo.FN_ListToTableInt(@CashierId)) OR
        (@CashierId = '' OR
        @CashierId IS NULL)) 
         -- Si trae valor en  @UserId es por que es MANAGER y consulta todos los registros ADMIN y MANAGER 
        AND ( ( @UserId IS NOT NULL AND TimeSheet.AgencyId IS NULL  ) OR 

                (dbo.Agencies.AgencyId IN (SELECT item -- Si @ListAgencyId tiene agencias es por que está haciendo la consulta a un MANAGER  en este caso
                --se consulta toda la informacion de usuarios relacionados a las AGENCIAS donde el @UserId es MANAGER
              FROM dbo.FN_ListToTableInt(@ListAgencyId)) OR 
                (@ListAgencyId = '' OR   
                @ListAgencyId IS NULL))) AND


        (CAST(dbo.TimeSheet.LoginDate AS date) >= CAST(@DateFrom AS date) OR
        @DateFrom IS NULL) AND
        ((dbo.Agencies.AgencyId IS NOT NULL AND
        CAST(dbo.TimeSheet.LogoutDate AS date) <= CAST(@DateTo AS date) OR
        @DateTo IS NULL)
        --query logout date para admin/managers= Cuando estamos consultando la informacion para un admin o manager, el sistema compara
        --la fecha de logout con la fecha fin del filtro en caso de llegar una, en el caso contrario, el siste consulta la fecha fin del filtro contra el logindate del mismo registro
        OR ((dbo.Agencies.AgencyId IS NULL AND
        ((CAST(dbo.TimeSheet.LogoutDate AS date) <= CAST(@DateTo AS date) AND
        dbo.TimeSheet.LogoutDate IS NOT NULL) OR
        (dbo.TimeSheet.LogoutDate IS NULL AND
        CAST(dbo.TimeSheet.LoginDate AS date) <= CAST(@DateTo AS date))) OR
        @DateTo IS NULL))) 
--        AND
--        dbo.Cashiers.IsActive = 1 // comentado por JF task 5817 
        ) AS QUERY
    WHERE
          --Where to cashiers= Cuando se quiere consultar por aprobados, entonces validamos si el registro ya tenía en bd el status C02
          --O si tiene otro status en bd pero el tiempo exedido no es mayor a 0 se da el registro por
          --aprobado logicamente(Es decir que es un estado que el sistema entiende, mas no está guardado fisicamente en bd)
          (QUERY.AgencyId IS NOT NULL AND
          (@StatusCode = 'C02'-- APPROVED
          AND (QUERY.ExitTimeExceded <= 0 OR
          QUERY.StatusCode = 'C02'))
          --Cuando se quiere consultar por pendings, entonces validamos si el registro en bd tiene un status difernte de C02(APPROVED)
          --Y que el tiempo excedido sea mayor a 0, en este caso se da por entendido que el registro está en pending
          OR (@StatusCode = 'C01'--PENDING
          AND (QUERY.ExitTimeExceded > 0 AND
          (QUERY.StatusCode <> 'C02' OR
          QUERY.StatusCode IS NULL))) OR
          @StatusCode IS NULL)
          --Where to admin/manager = Cuando se quiere consultar por aprroved, solo basta con validar que el logout date tenga un valor
          OR (QUERY.AgencyId IS NULL AND
          ((@StatusCode = 'C02' AND
          (QUERY.LogoutDate IS NOT NULL OR
          QUERY.StatusCode = 'C02'))
          --Cuando se quiere consultar por pending, solo basta con preguntar si el logout date está vacio o si el el timesheet tiene un status diferente de C02(APRROVED)
          OR ((@StatusCode = 'C01'--PENDING
          AND QUERY.LogoutDate IS NULL AND
          (QUERY.StatusCode IS NULL OR
          QUERY.StatusCode <> 'C02')
          ))) OR
          @StatusCode IS NULL)


  END;
GO