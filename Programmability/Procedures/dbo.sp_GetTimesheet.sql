SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--UPDATE Felipe 
--Date: 21-11-2023
--task: 5494

--UpdatedBy JF, UpdatedON 21-Mayo-2024 , task 5819

CREATE PROCEDURE [dbo].[sp_GetTimesheet] @CashierId INT = NULL, @DateFrom DATETIME = NULL, @DateTo DATETIME = NULL, @StatusCode VARCHAR(4) = NULL, @TimeSheetId INT = NULL, @UserId INT = NULL
AS
BEGIN

    DECLARE @ListAgencyId AS nchar(1000); --Se busca solo las agencias cuando es MANAGER y sabemos que es MANAGER cuando trae un valor en el 
    -- @UserId de lo contrario sería ADMIN
    SET @ListAgencyId = (SELECT STRING_AGG(AgencyId, ',')
  FROM AgenciesxUser aus
  WHERE aus.UserId = @UserId) 

  SELECT
    TimeSheetId
   ,LoginDateFormat
   ,LogoutDateFormat
   ,ApprovedOnFormat
   ,AgencyId
   ,UPPER(AgencyName) AgencyName
   ,UPPER(AgencyCodeName) AgencyCodeName
   ,UPPER(UserName) UserName
   ,EstimatedDepartureTimeFormat
   ,DayWork
   ,UPPER(Name) [Name]
   ,HoursWorked
   ,ExitTimeExceded
   ,ApprovedByName
   ,UserId
   ,LastUpdatedOn
   ,LastUpdatedBy
   ,EstimatedDepartureTime
   ,StatusId
   ,ApprovedOn
   ,ApprovedBy
   ,Description
   ,EstimatedDepartureTimeHHmm
   ,PreApproved
   ,CASE--Status-cashier= a)pending is when record has agencyId and ExitTimeExceded > 0
      --b)aprovved is when record has agencyId and ExitTimeExceded <= 0

      --Status-admin/manager= a)pending is when record Hasn’t agencyId and LogoutDate IS NULL
      --b)aprovved is when record Hasn’t agencyId and LogoutDate IS NOT NULL
      WHEN ((AgencyId IS NOT NULL AND
        ExitTimeExceded <= 0) OR
        AgencyId IS NULL AND
        LogoutDate IS NOT NULL) OR
        StatusId = 2 THEN 'APPROVED'
      ELSE 'PENDING'
    END AS Status
   ,CASE
      WHEN ((AgencyId IS NOT NULL AND
        ExitTimeExceded <= 0) OR
        AgencyId IS NULL AND
        LogoutDate IS NOT NULL) OR
        StatusId = 2 THEN 'C02'
      ELSE 'C01'
    END AS StatusCode
   ,StatusCode StatusCodeOrigin
   ,[dbo].fn_CalculateFractionToTimeString(HoursWorked) AS HoursWorkedFormatTime
   ,[dbo].fn_CalculateFractionToTimeString(ExitTimeExceded) AS ExitTimeExcededFormatTime
    --  ,
    --  --StatusId Status,
    --  RIGHT('0' + CAST(FLOOR(COALESCE(HoursWorked * 60, 0) / 60) AS varchar(8)), 2) + ':' +
    --  RIGHT('0' + CAST(FLOOR(COALESCE(HoursWorked * 60, 0) % 60) AS varchar(2)), 2) + ':' +
    --  RIGHT('0' + CAST(FLOOR(((SELECT dbo.fn_GetNumberRoundUp(HoursWorked) * 60) * 60) % 60) AS varchar(2)), 2) HoursWorkedFormatTime


    --  , RIGHT('0' + CAST(FLOOR(COALESCE(ABS(ExitTimeExceded) * 60, 0) / 60) AS varchar(8)), 2) + ':' +
    --  RIGHT('0' + CAST(FLOOR(COALESCE(ABS(ExitTimeExceded) * 60, 0) % 60) AS varchar(2)), 2) + ':' +
    --  RIGHT('0' + CAST(FLOOR(((SELECT dbo.fn_GetNumberRoundUp(ABS(ExitTimeExceded)) * 60) * 60) % 60) AS varchar(2)), 2) ExitTimeExcededFormatTime
   ,LoginDate
   ,LogoutDate
--   ,FORMAT(CAST(LoginDate AS DATETIME), 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LoginDate
--   ,FORMAT(CAST(LogoutDate AS DATETIME), 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LogoutDate
  FROM (SELECT
      dbo.TimeSheet.*

      ,FORMAT(CAST(TimeSheet.LoginDate AS DATETIME), 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LoginDateFormat
      ,FORMAT(CAST(TimeSheet.LogoutDate AS DATETIME), 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LogoutDateFormat
      ,FORMAT(CAST(TimeSheet.ApprovedOn AS DATETIME), 'MM-dd-yyyy h:mm:ss tt ', 'en-US') ApprovedOnFormat



--     ,FORMAT(TimeSheet.LoginDate, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LoginDateFormat
--     ,FORMAT(TimeSheet.LogoutDate, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LogoutDateFormat
--     ,FORMAT(TimeSheet.ApprovedOn, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') ApprovedOnFormat
     ,dbo.Agencies.Name AS AgencyName
     ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyCodeName
     ,dbo.Users.Name AS UserName
     ,FORMAT(CAST(EstimatedDepartureTime AS DATETIME), 'hh:mm tt') EstimatedDepartureTimeFormat
     ,FORMAT(LoginDate, 'dddd') DayWork
     ,dbo.Users.Name
     ,ut.Desciption AS Description
     ,CASE
        WHEN dbo.TimeSheet.LogoutDate IS NULL THEN 0
        ELSE
          --ISNULL(CONVERT(INT, DATEADD(SECOND, DATEDIFF(second,LoginDate,LogOutDate),0), 108),0)
          CAST(ISNULL(DATEDIFF(SECOND, LoginDate, LogoutDate) / 3600.0, 0) AS DECIMAL(18, 4))
      --                       ((DATEDIFF(second, LoginDate, LogOutDate))) / 3600.00
      END AS HoursWorked
     ,CAST(ISNULL(DATEDIFF(SECOND, DATEDIFF(dd, 0, LogoutDate) + CONVERT(DATETIME, EstimatedDepartureTime), LogoutDate) / 3600.0, 0) AS DECIMAL(18, 4)) ExitTimeExceded
     ,ts.Code AS StatusCode
     ,ap.Name AS ApprovedByName
     ,FORMAT(CAST(EstimatedDepartureTime AS DATETIME), 'HH:mm') AS EstimatedDepartureTimeHHmm


    FROM dbo.TimeSheet

    LEFT JOIN dbo.Agencies
      ON dbo.TimeSheet.AgencyId = dbo.Agencies.AgencyId
    INNER JOIN dbo.Users
      ON dbo.TimeSheet.UserId = dbo.Users.UserId
    LEFT JOIN dbo.Users ap
      ON dbo.TimeSheet.ApprovedBy = ap.UserId
    INNER JOIN dbo.Cashiers
      ON dbo.Users.UserId = dbo.Cashiers.UserId
    LEFT JOIN dbo.TimeSheetStatus ts
      ON ts.Id = dbo.TimeSheet.StatusId

    INNER JOIN UserTypes ut
      ON dbo.TimeSheet.Rol = ut.UsertTypeId

    WHERE (@CashierId IS NULL
    OR dbo.Cashiers.CashierId = @CashierId)
--    AND ((@UserId IS NOT NULL
--    AND Rol <> 1)
--    OR @UserId IS NULL)
    AND (@TimeSheetId IS NULL
    OR dbo.TimeSheet.TimeSheetId = @TimeSheetId)
    AND (CAST(dbo.TimeSheet.LoginDate AS DATE) >= CAST(@DateFrom AS DATE)
    OR @DateFrom IS NULL)
    AND (CAST(dbo.TimeSheet.LoginDate AS DATE) >= CAST(@DateFrom AS DATE)
    OR @DateFrom IS NULL)
    --query logout date para cashiers
    AND ((dbo.Agencies.AgencyId IS NOT NULL
    AND CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE)
    OR @DateTo IS NULL)
    --query logout date para admin/managers= Cuando estamos consultando la informacion para un admin o manager, el sistema compara
    --la fecha de logout con la fecha fin del filtro en caso de llegar una, en el caso contrario, el siste consulta la fecha fin del filtro contra el logindate del mismo registro
    OR ((dbo.Agencies.AgencyId IS NULL
    AND ((CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE)
    AND dbo.TimeSheet.LogoutDate IS NOT NULL)
    OR (dbo.TimeSheet.LogoutDate IS NULL
    AND CAST(dbo.TimeSheet.LoginDate AS DATE) <= CAST(@DateTo AS DATE)))
    OR @DateTo IS NULL)))  
 -- Si trae valor en  @UserId es por que es MANAGER y consulta todos los registros ADMIN y MANAGER 
    AND (( @UserId IS NOT NULL AND TimeSheet.AgencyId IS NULL ) OR  
    (dbo.Agencies.AgencyId IN (SELECT item -- Si @ListAgencyId tiene agencias es por que está haciendo la consulta a un MANAGER  en este caso
    --se consulta toda la informacion de usuarios relacionados a las AGENCIAS donde el @UserId es MANAGER
      FROM dbo.FN_ListToTableInt(@ListAgencyId)) OR
        (@ListAgencyId = '' OR
        @ListAgencyId IS NULL)))


  --AND ((dbo.Agencies.AgencyId <> NULL
  --AND dbo.TimeSheet.LogoutDate <> NULL
  --AND CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE)
  --OR @DateTo IS NULL)
  --OR (((dbo.Agencies.AgencyId = NULL AND CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE))
  --OR dbo.TimeSheet.LogoutDate = NULL)
  --OR @DateTo IS NULL
  --))

  --      AND 
  --      dbo.Cashiers.IsActive = 1 AND // comentado por JF task 5817 

 


  ) AS QUERY
  WHERE
  --Where to cashiers= Cuando se quiere consultar por aprobados, entonces validamos si el registro ya tenía en bd el status C02
  --O si tiene otro status en bd pero el tiempo exedido no es mayor a 0 se da el registro por
  --aprobado logicamente(Es decir que es un estado que el sistema entiende, mas no está guardado fisicamente en bd)
  (QUERY.AgencyId IS NOT NULL
  AND (@StatusCode = 'C02'-- APPROVED
  AND (QUERY.ExitTimeExceded <= 0
  OR QUERY.StatusCode = 'C02'))
  --Cuando se quiere consultar por pendings, entonces validamos si el registro en bd tiene un status difernte de C02(APPROVED)
  --Y que el tiempo excedido sea mayor a 0, en este caso se da por entendido que el registro está en pending
  OR (@StatusCode = 'C01'--PENDING
  AND (QUERY.ExitTimeExceded > 0
  AND (QUERY.StatusCode <> 'C02'
  OR QUERY.StatusCode IS NULL)))
  OR @StatusCode IS NULL)
  --Where to admin/manager = Cuando se quiere consultar por aprroved, solo basta con validar que el logout date tenga un valor
  OR (QUERY.AgencyId IS NULL
  AND ((@StatusCode = 'C02'
  AND (QUERY.LogoutDate IS NOT NULL
  OR QUERY.StatusCode = 'C02'))
  --Cuando se quiere consultar por pending, solo basta con preguntar si el logout date está vacio o si el el timesheet tiene un status diferente de C02(APRROVED)
  OR ((@StatusCode = 'C01'--PENDING
  AND QUERY.LogoutDate IS NULL
  AND (QUERY.StatusCode IS NULL
  OR QUERY.StatusCode <> 'C02')
  )))
  OR @StatusCode IS NULL)
  ORDER BY QUERY.LoginDate;
END;


GO