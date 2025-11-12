SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Create by Felipe 
--Create date 8-Enero-2023
--Task 5550

CREATE PROCEDURE [dbo].[sp_GetReportCashAdvanceOrBack]
(
                 @AgencyId int, @FromDate datetime = NULL, @ToDate datetime = NULL, @Date datetime, @ProviderId int
)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;



  SELECT 'CASH ADVANCE OR BACK' AS Type,
  caob.CreationDate,
  'CASH ADVANCE OR BACK ID ' + caob.TransactionId AS Description,
  ABS(caob.Usd) Usd,
  u.Name AS Employee
  FROM CashAdvanceOrBack caob
       INNER JOIN
       dbo.Users u
       ON u.UserId = caob.CreatedBy
  WHERE caob.AgencyId = @AgencyId AND
        ProviderId = @ProviderId AND
        CAST(caob.CreationDate AS date) >= CAST(@FromDate AS date) AND
        CAST(caob.CreationDate AS date) <= CAST(@ToDate AS date)
  ORDER BY caob.CreationDate ASC


END;
GO