SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
	exec [dbo].[sp_GetAllProvisionalReceipts]
	@Completed = NULL,
	@CompanyName = NULL,
	@FromDate = '2020-05-27',
	@ToDate = '2020-05-27',
	@AgencyId = 12,
	@CashierId = '130',
	@CompanyId = NULL
*/

--UPDATE Felipe oquendo
--task 5541 Mejora búsqueda, módulo provisional receipts
--date: 27-11-2023

CREATE PROCEDURE [dbo].[sp_GetAllProvisionalReceipts] @Completed    BIT          = NULL, 
                                                     @CompanyName  VARCHAR(30)  = NULL, 
                                                     @FromDate     DATE         = NULL, 
                                                     @ToDate       DATE         = NULL, 
                                                     @AgencyId     INT          = NULL, 
                                                     @CashierId    VARCHAR(500) = NULL, 
                                                     @CompanyId    INT          = NULL, 
                                                     @ClientName   VARCHAR(50)  = NULL, 
                                                     @Telephone    VARCHAR(15)  = NULL, 
                                                     @TelephoneUSA VARCHAR(15)  = NULL, 
                                                     @Account      VARCHAR(50)  = NULL, 
                                                     @IsManager AS    BIT          = NULL, 
                                                     @IsAdmin AS      BIT          = NULL, 
                                                     @IsCashier AS    BIT          = NULL
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT pr.ProvisionalReceiptId, 
               UPPER(pr.CompanyName) CompanyName, 
               pr.Total, 
               pr.OtherFees, 
               pr.CardPaymentFee, 
               pr.CardPayment, 
               pr.Cash, 
               pr.Change, 
               pr.Completed, 
               pr.AgencyId, 
               pr.CreatedBy, 
               pr.CreationDate,
			   FORMAT(pr.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               pr.CompletedBy, 
               uC.Name CompletedByName, 
               pr.CompletedOn, 
			   FORMAT(pr.CompletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CompletedOnFormat,
               pr.Telephone, 
               pr.Telephone AS TelephoneSaved, 
               pr.TelephoneUSA, 
               ISNULL(pr.AccountIsCheck, CAST(0 AS BIT)) AccountIsCheck, 
               ISNULL(pr.TelIsCheck, CAST(0 AS BIT)) TelIsCheck, 
               pr.ClientName, 
               pr.CompanyId, 
               pr.CountryId,
               CASE
                   WHEN pr.Completed = 1
                   THEN 'COMPLETED'
                   ELSE 'PENDING'
               END AS [Status], 
               (pr.Total + pr.OtherFees + pr.CardPaymentFee) AS TotalToPaid, 
               UPPER(a.Code + ' - ' + a.Name) Agency, 
               u.Name AS Cashier, 
               pr.Account, 
               pr.Account AS AccountSaved, 
               it.code AS internationalTypeCode, 
               pr.TypeOfInternationalTopUpsId, 
               pr.TransactionNumber
        FROM [dbo].ProvisionalReceipts pr
             INNER JOIN Agencies A ON a.AgencyId = pr.AgencyId
             INNER JOIN Cashiers c ON c.CashierId = pr.CreatedBy
             INNER JOIN Users u ON u.userId = c.UserId
             LEFT JOIN Cashiers cc ON cc.CashierId = pr.CompletedBy
             LEFT JOIN Users uC ON uC.userId = cC.UserId
             LEFT JOIN dbo.Companies cp ON pr.CompanyId = cp.CompanyId
             LEFT JOIN TypeOfInternationalTopUps it ON it.TypeOfInternationalTopUpsId = pr.TypeOfInternationalTopUpsId
        WHERE(Completed = @Completed
              OR @Completed IS NULL)
             AND (Account LIKE '%' + @Account + '%'
                  OR @Account IS NULL)
             AND (pr.ClientName LIKE '%' + @ClientName + '%'
                  OR @ClientName IS NULL)
             AND (pr.Telephone LIKE '%' + @Telephone + '%'
                  OR @Telephone IS NULL)
             AND (pr.TelephoneUSA LIKE '%' + @TelephoneUSA + '%'
                  OR @TelephoneUSA IS NULL)
             AND (pr.CompanyId = @CompanyId
                  OR @CompanyId IS NULL
                  OR @CompanyId = '')
             AND (((@IsCashier = 1 OR @IsAdmin = 1)             
             AND (pr.AgencyId = @AgencyId OR @AgencyId IS NULL)
                   AND (c.CashierId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@CashierId)
        )
                  OR (@CashierId = ''
                      OR @CashierId IS NULL)))
        OR ((@IsManager = 1
             AND ((@AgencyId IS NULL
                   AND pr.AgencyId IN
        (
            SELECT AgencyId
            FROM AgenciesxUser a
                 INNER JOIN Cashiers C ON C.UserId = a.UserId
            WHERE(C.CashierId IN
            (
                SELECT item
                FROM dbo.FN_ListToTableInt(@CashierId)
            ))
        ))
             OR (pr.AgencyId = @AgencyId
                 AND (c.CashierId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@CashierId)
        )
        OR (@CashierId = ''
            OR @CashierId IS NULL)))))))
        AND ((((CAST(pr.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
               OR @FromDate IS NULL))
             AND ((CAST(pr.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
                  OR @ToDate IS NULL) AND ( @Completed = 0 OR @Completed IS NULL ))

          OR (((CAST(pr.CompletedOn AS DATE) >= CAST(@FromDate AS DATE)
               OR @FromDate IS NULL))
             AND ((CAST(pr.CompletedOn AS DATE) <= CAST(@ToDate AS DATE))
                  OR @ToDate IS NULL) AND @Completed = 1))
        ORDER BY ProvisionalReceiptId ASC;
    END;

GO