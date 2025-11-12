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

CREATE PROCEDURE [dbo].[sp_GetAllProvisionalReceiptsPendingDaily] @Completed   BIT          = NULL, 
                                                    
                                                     @AgencyId    INT          = NULL, 
                                                     @CashierId   VARCHAR(500) = NULL 
                                                    
AS
     SET NOCOUNT ON;
    BEGIN
       SELECT  top 1 *
	  --pr.ProvisionalReceiptId, 
      --         UPPER(pr.CompanyName) CompanyName, 
      --         pr.Total, 
      --         pr.OtherFees, 
      --         pr.CardPaymentFee, 
      --         pr.CardPayment, 
      --         pr.Cash, 
      --         pr.Change, 
      --         pr.Completed, 
      --         pr.AgencyId, 
      --         pr.CreatedBy, 
      --         pr.CreationDate, 
      --         pr.CompletedBy, 
      --         uC.Name CompletedByName, 
      --         pr.CompletedOn, 
      --         pr.Telephone,
			   --pr.Telephone AS TelephoneSaved, 
      --         pr.TelephoneUSA, 
              
      --         ISNULL(pr.AccountIsCheck, CAST(0 AS BIT)) AccountIsCheck, 
      --         ISNULL(pr.TelIsCheck, CAST(0 AS BIT)) TelIsCheck, 
      --         pr.ClientName, 
      --         pr.CompanyId,
			   --pr.CountryId,
      --         CASE
      --             WHEN pr.Completed = 1
      --             THEN 'COMPLETED'
      --             ELSE 'PENDING'
      --         END AS Status, 
      --         (pr.Total + pr.OtherFees + pr.CardPaymentFee) AS TotalToPaid, 
      --         UPPER(a.Code + ' - ' + a.Name) Agency, 
      --         u.Name AS Cashier, 
      --         pr.Account,
			   --pr.Account as AccountSaved,
			   --it.code as internationalTypeCode,
			   --pr.TypeOfInternationalTopUpsId
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
          
             AND (pr.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)
           
             AND (c.CashierId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@CashierId)
        )
        OR (@CashierId = ''
            OR @CashierId IS NULL))

    END;
GO