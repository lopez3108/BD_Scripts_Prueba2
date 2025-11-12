SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetSystemToolsBill] @UserId   INT =NULL, 
                                               @FromDate DATE, 
                                               @ToDate   DATE,
											   @AgencyId INT = NULL
AS
    BEGIN
        SELECT s.BillId, 
		s.CreatedBy,
               s.CreationDate,
               FORMAT(s.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat, 
			   s.LastUpdatedOn,
          FORMAT(s.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastUpdatedOnFormat, 
			  
               s.Total, 
               s.Change, 
               s.Cash, 
               s.CardPaymentFee, 

                CASE
                   WHEN s.CardPayment = 1
                   THEN 'YES'
                   ELSE 'NO'
               END AS [CardPaymentFormat],

			   s.AgencyId,
        (
            SELECT COUNT(BillId)
            FROM SystemToolsValues
            WHERE s.billId = BillId
        ) AS numberBills, 
               UPPER(dbo.Users.Name) AS CreatedByName, 
			    UPPER(us.Name) AS LastUpdatedByName, 
               ISNULL(S.CardPayment, CAST(0 AS BIT)) CardPayment,
			   UPPER(a.Code + ' - ' + a.Name) AgencyName
        FROM SystemToolsBill s
             INNER JOIN dbo.Users ON dbo.Users.UserId = s.CreatedBy
			 INNER JOIN Users us ON us.UserId = s.LastUpdatedBy
			   INNER JOIN Agencies A ON a.AgencyId = s.AgencyId
        WHERE(s.CreatedBy = @UserId OR @UserId IS NULL) AND
		(s.AgencyId = @AgencyId OR @AgencyId IS NULL)
             AND ((CAST(s.CreationDate AS DATE) >= CAST(@FromDate AS DATE))
                  AND (CAST(s.CreationDate AS DATE) <= CAST(@ToDate AS DATE)));
    END;
  

GO