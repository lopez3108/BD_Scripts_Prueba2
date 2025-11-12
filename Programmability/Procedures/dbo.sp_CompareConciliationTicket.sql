SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 27-12-2024 JT/6233: Conciliación tickets by transaction ID
-- 18-03-2025 JT/6233: Conciliación tickets by transaction ID

CREATE PROCEDURE [dbo].[sp_CompareConciliationTicket] @TicketConciliationTable ConciliationTypeTable1 READONLY,
@UserId INT,
@CompletedDate DATETIME,
@StatusCode VARCHAR(3)
AS
BEGIN
  DECLARE @Status INT;

  -- Obtener Status
  SELECT
    @Status = TicketStatusId
  FROM TicketStatus
  WHERE Code = @StatusCode;

  WITH DuplicateCheck
  AS
  (SELECT
      TransactionId
     ,COUNT(*) AS DuplicateCount
    FROM @TicketConciliationTable
    WHERE TransactionId IS NOT NULL
    GROUP BY TransactionId
    HAVING COUNT(*) > 1 -- Identifica registros duplicados
  )


  -- Crear tabla temporal para errores y registros válidos
  SELECT
    UPPER(O.TransactionId) TransactionId
   ,O.TransactionFee
   ,
    --        O.CityCompletedDate,
    CAST(O.CityCompletedDate AS DATE) AS CityCompletedDate
   ,  -- Aquí convertimos a DATE
    CASE
      WHEN TRY_CONVERT(DATETIME, O.CityCompletedDate) IS NULL THEN 'cityCompletedDate_error_conciliation_tickets'
      WHEN TRY_CONVERT(DECIMAL(18, 2), O.TransactionFee) IS NULL THEN 'fee_error_format_conciliation_tickets'
      WHEN TRY_CONVERT(DECIMAL(18, 2), O.TransactionFee) < 0 THEN 'fee_negative_value_conciliation_tickets'
      WHEN D.TransactionId IS NOT NULL THEN 'duplicate_transactionid_error' -- Marcamos duplicados
      WHEN T.TransactionId IS NULL OR
        T.TransactionId = '' OR
        T.TransactionId = ' ' THEN 'transactionid_error_conciliation_tickets'
      WHEN O.TransactionId IS NULL OR
        O.TransactionId = '' OR
        O.TransactionId = ' ' THEN 'transactionid_error_conciliation_tickets'
      WHEN T.TicketStatusId = @Status THEN 'ticket_status_error_conciliation_tickets'
      WHEN CAST(O.CityCompletedDate AS DATE) < CAST(T.CreationDate AS DATE) THEN 'completed_date_less_than_creation_date_error'
      WHEN CAST(O.CityCompletedDate AS DATE) > CAST(@CompletedDate AS DATE) THEN 'city_completed_date_must_equal_alert'

      WHEN TRY_CONVERT(DECIMAL(18, 2), ISNULL(O.TransactionFee, 0)) <> ISNULL(T.Usd, 0) THEN 'fee_error_conciliation_tickets'

      ELSE 'ok'
    END AS errorMessage INTO #TicketsTemp
  FROM @TicketConciliationTable O
  LEFT JOIN dbo.Tickets T
    ON UPPER(O.TransactionId) = UPPER(T.TransactionId)
  LEFT JOIN DuplicateCheck D
    ON UPPER(O.TransactionId) = UPPER(D.TransactionId) -- Verificación de duplicados
  --  WHERE O.TransactionId IS NOT NULL;

  -- Actualizar los registros válidos que están "ok" en la tabla temporal
  UPDATE T
  SET T.LastUpdatedOn = @CompletedDate
     ,T.LastUpdatedBy = @UserId
     ,T.CompletedBy = @UserId
     ,T.CompletedDate = @CompletedDate
     ,T.CityCompletedDate = V.CityCompletedDate
     ,T.TicketStatusId = @Status
  FROM dbo.Tickets T
  INNER JOIN #TicketsTemp V
    ON UPPER(T.TransactionId COLLATE SQL_Latin1_General_CP1_CI_AS) = UPPER(V.TransactionId COLLATE SQL_Latin1_General_CP1_CI_AS)
  WHERE TRY_CONVERT(DECIMAL(18, 2), V.TransactionFee) = ISNULL(T.Usd, 0)
  AND T.TicketStatusId <> @Status
  AND V.errorMessage = 'ok';


  -- Mostrar registros con errores (diferentes a "ok")
  SELECT
    *
  FROM #TicketsTemp
  WHERE errorMessage IS NOT NULL
  AND errorMessage <> 'ok';

  -- Limpiar tabla temporal
  DROP TABLE #TicketsTemp;

END





GO