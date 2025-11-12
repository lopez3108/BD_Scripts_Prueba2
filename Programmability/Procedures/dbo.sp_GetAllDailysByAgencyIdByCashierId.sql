SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Update by JT/02-09-2025 TASK 6689 Daily report nueva columna TOTAL CASH DAILY ADMIN SE LE SUMA EL CASH DISTRIBUTED
CREATE PROCEDURE [dbo].[sp_GetAllDailysByAgencyIdByCashierId]
(
    @AgencyId   INT        = NULL,
    @UserId     INT        = NULL,
    @Status     VARCHAR(20),
    @FromDate   DATETIME   = NULL,
    @ToDate     DATETIME   = NULL,
    @CurrentDate DATETIME
)
AS
BEGIN
  SET ANSI_WARNINGS OFF;
  SET NOCOUNT ON;

  /* Fechas sargables (mejor para índices que CAST(col AS DATE)) */
  DECLARE @FromStart  DATETIME = CASE WHEN @FromDate IS NULL THEN NULL
                                      ELSE DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), 0) END;
  DECLARE @ToNextDay  DATETIME = CASE WHEN @ToDate   IS NULL THEN NULL
                                      ELSE DATEADD(DAY, DATEDIFF(DAY, 0, @ToDate) + 1, 0) END;
  DECLARE @TodayStart DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @CurrentDate), 0);
  DECLARE @TodayNext  DATETIME = DATEADD(DAY, 1, @TodayStart);

  /* Suma de distribuciones por DailyId (evita subconsultas repetidas) */
  WITH Dist AS
  (
      SELECT DD.DailyId,
             SUM(CONVERT(DECIMAL(19,4), DD.Usd)) AS DistUsd
      FROM dbo.DailyDistribution AS DD
      GROUP BY DD.DailyId
  )
  SELECT
    D.DailyId
   ,D.CashierId
   ,D.AgencyId
   ,D.CreationDate
   ,FORMAT(D.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') AS CreationDateFormat
   ,D.Total
   ,D.TotalFree
   ,D.Cash
   ,D.Note
   ,D.LastEditedOn
   ,D.LastEditedBy
   ,D.CashAdmin
   ,D.ClosedOn
   ,FORMAT(D.ClosedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') AS ClosedOnFormat
   ,D.ClosedBy
   ,D.CardPayments
   ,D.CardPaymentsAdmin
   ,D.ClosedOnCashAdmin
   ,D.ClosedByCashAdmin
   ,D.ClosedOnCardPaymentsAdmin
   ,UPPER(D.ClosedByCardPaymentsAdmin) AS ClosedByCardPaymentsAdmin

   /* Calculamos una sola vez la expresión legacy y derivamos Missing/Surplus */
   ,CASE
      WHEN (
            (
              (CASE
                 WHEN D.ClosedByCashAdmin > 0
                   THEN D.CashAdmin --Task 5371 el cash admin permite 0 como valor
                        + ISNULL(Ds.DistUsd, 0)
                 ELSE D.Cash
               END)
              +
              (CASE
                 WHEN D.CardPaymentsAdmin > 0 THEN D.CardPaymentsAdmin
                 ELSE D.CardPayments
               END)
            ) - D.Total
          ) < 0
      THEN
            (
              (CASE
                 WHEN D.ClosedByCashAdmin > 0
                   THEN D.CashAdmin --Task 5371 el cash admin permite 0 como valor
                        + ISNULL(Ds.DistUsd, 0)
                 ELSE D.Cash
               END)
              +
              (CASE
                 WHEN D.CardPaymentsAdmin > 0 THEN D.CardPaymentsAdmin
                 ELSE D.CardPayments
               END)
            ) - D.Total
      ELSE 0
    END AS Missing

   ,CASE
      WHEN (
            (
              (CASE
                 WHEN D.ClosedByCashAdmin > 0
                   THEN D.CashAdmin --Task 5371 el cash admin permite 0 como valor
                        + ISNULL(Ds.DistUsd, 0)
                 ELSE D.Cash
               END)
              +
              (CASE
                 WHEN D.CardPaymentsAdmin > 0 THEN D.CardPaymentsAdmin
                 ELSE D.CardPayments
               END)
            ) - D.Total
          ) > 0
      THEN
            (
              (CASE
                 WHEN D.ClosedByCashAdmin > 0
                   THEN D.CashAdmin --Task 5371 el cash admin permite 0 como valor
                        + ISNULL(Ds.DistUsd, 0)
                 ELSE D.Cash
               END)
              +
              (CASE
                 WHEN D.CardPaymentsAdmin > 0 THEN D.CardPaymentsAdmin
                 ELSE D.CardPayments
               END)
            ) - D.Total
      ELSE 0
    END AS Surplus

   ,ISNULL(D.CashAdmin, 0) AS CashAdminUsd
   ,UPPER(UC.Name) AS Cashier
   ,ISNULL(UC.UserId, 0) AS UserId
   ,UPPER(UCL.Name) AS ClosedByUser
   ,UCA.Name AS ClosedByCashAdminUser
   ,UCPA.Name AS ClosedByCardPaymentsAdminUser
   ,(A.Code + ' - ' + A.Name) AS Agency
  FROM dbo.Daily AS D
  INNER JOIN dbo.Cashiers AS C
    ON D.CashierId = C.CashierId
  INNER JOIN dbo.Users AS UC
    ON UC.UserId = C.UserId
  INNER JOIN dbo.Agencies AS A
    ON A.AgencyId = D.AgencyId
  LEFT JOIN dbo.Users AS UCL
    ON UCL.UserId = D.ClosedBy
  LEFT JOIN dbo.Users AS UCA
    ON UCA.UserId = D.ClosedByCashAdmin
  LEFT JOIN dbo.Users AS UCPA
    ON UCPA.UserId = D.ClosedByCardPaymentsAdmin
  LEFT JOIN Dist AS Ds
    ON Ds.DailyId = D.DailyId
  WHERE (C.UserId = @UserId OR @UserId IS NULL)
    AND (D.AgencyId = @AgencyId OR @AgencyId IS NULL)
    AND (
         (@Status = 'PENDING'
            AND (D.CreationDate >= @FromStart  OR @FromDate IS NULL)
            AND (D.CreationDate <  @ToNextDay  OR @FromDate IS NULL)
            AND (D.ClosedBy IS NULL AND D.ClosedOn IS NULL)
         )
      OR (@Status = 'ALL' --TRAE TODOS ICLUYENDO LOS DAILYS DE DIAS ACTUALES
            AND D.CreationDate >= @FromStart
            AND D.CreationDate <  @ToNextDay
         )
      OR (@Status = 'TODAY'
            AND D.CreationDate >= @TodayStart
            AND D.CreationDate <  @TodayNext
         )
    );
END;
GO