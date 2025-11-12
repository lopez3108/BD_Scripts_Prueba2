SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by 16-09-2024 task 6060 Ajuste payroll salary:  Edit DECIMAL(18, 7) by DECIMAL(18, 2) 
-- 2024-05-14 JT/5889:  Change lenght of field Hours DECIMAL(18, 7), for calculate the specific hour, minute,second

-- 2024-04-19 DJ/5808: Fraction time was not showing hundred character
--UpdatedBy JF, UpdatedON 22-Mayo-2024 , task 5815
CREATE PROCEDURE [dbo].[sp_GetTotalTimesheet] @CashierId INT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@StatusCode VARCHAR(4) = NULL,
@UserId INT = NULL
AS
BEGIN

  DECLARE @ListAgencyId AS NCHAR(1000); --Se busca solo las agencias cuando es MANAGER y sabemos que es MANAGER cuando trae un valor en el 
  -- @UserId de lo contrario sería ADMIN
  SET @ListAgencyId = (SELECT
      STRING_AGG(AgencyId, ',')
    FROM AgenciesxUser aus
    WHERE aus.UserId = @UserId)



  SELECT
    CAST(SumHours AS DECIMAL(18, 2)) SumHours
   ,[dbo].fn_CalculateFractionToTimeString(SumHours) AS SumHoursFormatTime
  FROM (SELECT
      CAST(ISNULL(SUM(Q.Hours), 0) AS DECIMAL(18, 2)) SumHours
    FROM ( --Se adiciona la SUM antes del cast para que redondeee cada registro
      SELECT
        (CAST(ISNULL(DATEDIFF(SECOND, LoginDate, LogoutDate) / 3600.0, 0) AS DECIMAL(18, 2))) Hours

       ,CAST(ISNULL(DATEDIFF(SECOND, DATEDIFF(dd, 0, LogoutDate) + CONVERT(DATETIME, EstimatedDepartureTime), LogoutDate) / 3600.0, 0) AS DECIMAL(18, 2)) ExitTimeExceded
       ,ts.Code AS StatusCode
      FROM dbo.TimeSheet
      --INNER JOIN dbo.Providers ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
      LEFT JOIN dbo.Agencies
        ON dbo.TimeSheet.AgencyId = dbo.Agencies.AgencyId
      INNER JOIN dbo.Users
        ON dbo.TimeSheet.UserId = dbo.Users.UserId
      INNER JOIN dbo.Cashiers
        ON dbo.Users.UserId = dbo.Cashiers.UserId
      LEFT JOIN dbo.TimeSheetStatus ts
        ON ts.Id = dbo.TimeSheet.StatusId
      WHERE (@CashierId IS NULL
      OR dbo.Cashiers.CashierId = @CashierId)
      --AND (CAST(dbo.TimeSheet.LoginDate AS DATE) >= CAST(@DateFrom AS DATE))
      --AND (CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE))

      AND (CAST(dbo.TimeSheet.LoginDate AS DATE) >= CAST(@DateFrom AS DATE)
      OR @DateFrom IS NULL)
      AND (CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE)
      OR @DateTo IS NULL)
      -- Si trae valor en  @UserId es por que es MANAGER y consulta solo los registros ADMIN y MANAGER relacionados a este @UserId
      AND ((@UserId IS NOT NULL
      AND TimeSheet.AgencyId IS NULL)
      OR (dbo.Agencies.AgencyId IN (SELECT
          item -- Si @ListAgencyId tiene agencias es por que está haciendo la consulta a un MANAGER  en este caso
        --se consulta toda la informacion de usuarios relacionados a las AGENCIAS donde el @UserId es MANAGER
        FROM dbo.FN_ListToTableInt(@ListAgencyId))
      OR (@ListAgencyId = ''
      OR @ListAgencyId IS NULL)))
    --      AND dbo.Cashiers.IsActive = 1
    --      GROUP BY LoginDate
    --              ,LogoutDate
    --              ,EstimatedDepartureTime
    --              ,ts.Code

    ) AS Q
    WHERE (@StatusCode = 'C02'
    AND (Q.ExitTimeExceded <= 0
    OR Q.StatusCode = 'C02'))
    OR (@StatusCode = 'C01'
    AND (Q.ExitTimeExceded > 0
    AND (Q.StatusCode <> 'C02'
    OR Q.StatusCode IS NULL)))
    OR @StatusCode IS NULL) QUE
  GROUP BY QUE.SumHours;
END;



GO