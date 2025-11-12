SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentBalance] @AgencyId   INT,
                                             @ProviderId INT      = NULL,
                                             @DateFrom   DATETIME,
                                             @DateTo     DATETIME,
											 @Year     INT = NULL,
											 @Month     INT = NULL
AS
     BEGIN
         SELECT dbo.PaymentBalance.PaymentBalanceId,
                dbo.Agencies.AgencyId,
                dbo.Agencies.Name AS AgencyName,
				dbo.Agencies.Code + ' - ' +  dbo.Agencies.Name AS AgencyCodeName,
                dbo.Providers.ProviderId,
                dbo.Providers.Name+ISNULL(
                                         (
                                             SELECT TOP 1 ' - '+dbo.MoneyTransferxAgencyNumbers.Number
                                             FROM dbo.MoneyTransferxAgencyNumbers
                                             WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentBalance.AgencyId
                                                   AND dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentBalance.ProviderId
                                         ), '') AS ProviderName,
                dbo.PaymentBalance.USD,
                dbo.PaymentBalance.CreationDate,
				FORMAT(PaymentBalance.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
                dbo.PaymentBalance.DeletedOn,
				FORMAT(PaymentBalance.DeletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  DeletedOnFormat,
			    dbo.PaymentBalance.FileBalance,
                UPPER(dbo.Users.Name) AS DeletedBy,
                CASE
                    WHEN dbo.PaymentBalance.DeletedOn IS NOT NULL
                    THEN 'DELETED'
                    ELSE 'ACTIVE'
                END AS Status,
                dbo.PaymentBalance.Date,
			    FORMAT(PaymentBalance.Date, 'MM-dd-yyyy', 'en-US')  DateBalanceFormat,
                UPPER(Users1.Name) AS CreatedByName,
				dbo.PaymentBalance.Cost,
				dbo.PaymentBalance.Commission,
				dbo.PaymentBalance.Year as YearName,
				dbo.PaymentBalance.Month,
				UPPER(DateName( month , DateAdd( month , dbo.PaymentBalance.Month , 0 ) - 1 )) as MonthName
         FROM dbo.PaymentBalance
              INNER JOIN dbo.Providers ON dbo.PaymentBalance.ProviderId = dbo.Providers.ProviderId
              INNER JOIN dbo.Agencies ON dbo.PaymentBalance.AgencyId = dbo.Agencies.AgencyId
              LEFT OUTER JOIN dbo.Users ON dbo.PaymentBalance.DeletedBy = dbo.Users.UserId
              INNER JOIN dbo.Users AS Users1 ON dbo.PaymentBalance.CreatedBy = Users1.UserId
         WHERE dbo.PaymentBalance.AgencyId = @AgencyId
               AND dbo.PaymentBalance.ProviderId = CASE
                                                       WHEN @ProviderId IS NULL
                                                       THEN dbo.PaymentBalance.ProviderId
                                                       ELSE @ProviderId
                                                   END
               AND CAST(dbo.PaymentBalance.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
               AND CAST(dbo.PaymentBalance.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
			   AND (@Year is NULL OR @Year = dbo.PaymentBalance.Year)
			   AND (@Month is NULL OR @Month = dbo.PaymentBalance.Month)
     END;
GO