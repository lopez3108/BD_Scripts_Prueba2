SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllInstructionChange] @FromDate          DATE        = NULL, 
                                                   @ToDate            DATE        = NULL, 
                                                   @AgencyId          INT         = NULL, 
                                                   @ProviderId        INT         = NULL, 
                                                   @TransactionNumber VARCHAR(15) = NULL, 
                                                   @Telephone         VARCHAR(10) = NULL, 
                                                   @ClientName        VARCHAR(50) = NULL, 
                                                   @StatusId          INT         = NULL, 
                                                   @ChangeTypeId      INT         = NULL
AS
    BEGIN
        SELECT it.InstructionChangeId, 
               it.CreationDate, 
			   FORMAT(it.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
                      it.ClientName, 
                      it.TransactionNumber, 
                      it.StatusId, 
                      it.ChangeTypeId, 
                      it.ProviderId, 
                      it.NewProviderId, 
                      it.Telephone, 
                      it.CreatedBy, 
                      it.AgencyId, 
                      it.NewPayer, 
                      it.InstructionPaymentId, 
                      it.Account, 
                      it.Account AccountSaved, 
                      it.NewRecipient, 
                      it.CancellationReason, 
                      it.ValidationCode, 
                      it.isSent, 
                      IC.Code, 
                      it.RecipientName, 
                      it.NewKey, 
                      it.Note, 
                      it.LastUpdatedBy, 
                      it.LastUpdatedOn, 
                      FORMAT(it.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastUpdatedOnFormat,
                      it.ValidatedBy, 
                      it.ValidatedOn, 
                      it.Usd, 
                      it.AccountIsCheck, 
                      it.IsReenter, 
                      it.Email, 
                      it.Request,
                      UPPER(a.Code + ' - ' + a.Name) AgencyName, 
                      UPPER(u.Name) AS CreatedByName, 
                      UPPER(ul.Name) AS LastUpdatedByName, 
                      UPPER(va.Name) AS ValidatedByName, 
                      UPPER(p.Name) AS ProviderName, 
                      UPPER(pn.Name) AS NewProviderName, 
                      UPPER(ic.Description) AS DescriptionStatus, 
                      UPPER(ct.Description) AS ChangeStatus, 
                      UPPER(ip.Description) AS PaymentStatus, 
                      UPPER(it.CityName) AS NewCity, 
                      --CAST(it.Request AS BIT) AS Request, 
                      CAST(it.ChooseMsg AS BIT) AS ChooseMsg, 
                      CAST(it.OperationType AS BIT) AS OperationType,
                      it.ChangeReasonId,
                      it.NewTransactionNumber

     FROM [dbo].InstructionChange it
             INNER JOIN Agencies A ON a.AgencyId = it.AgencyId
             INNER JOIN InstructionChangeStatus ic ON ic.StatusId = it.StatusId
             LEFT JOIN InstructionPaymentStatus ip ON ip.InstructionPaymentId = it.InstructionPaymentId
             LEFT JOIN ChangeTypeStatus ct ON ct.ChangeTypeId = it.ChangeTypeId
             LEFT JOIN Providers p ON p.ProviderId = it.ProviderId
			      LEFT JOIN Providers pn ON pn.ProviderId = it.NewProviderId
             INNER JOIN Providertypes pt ON pt.ProviderTypeId = p.ProviderTypeId
             INNER JOIN Users u ON u.UserId = it.CreatedBy
             LEFT JOIN Users ul ON ul.UserId = it.LastUpdatedBy
             LEFT JOIN Users va ON va.UserId = it.ValidatedBy
             LEFT JOIN dbo.Cashiers ON dbo.Cashiers.UserId = u.UserId
        WHERE(it.AgencyId = @AgencyId)
             AND (it.StatusId = @StatusId
                  OR @StatusId IS NULL)
             AND (it.ChangeTypeId = @ChangeTypeId
                  OR @ChangeTypeId IS NULL)
             AND (it.ProviderId = @ProviderId
                  OR @ProviderId IS NULL)
             AND (it.TransactionNumber = @TransactionNumber
                  OR @TransactionNumber IS NULL)
             AND (it.ClientName LIKE '%' + @ClientName + '%'
                  OR @ClientName IS NULL)
             AND (it.Telephone = @Telephone
                  OR @Telephone IS NULL)
             AND ((CAST(it.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   OR @FromDate IS NULL)
                  AND (CAST(it.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
                  OR @ToDate IS NULL)
        ORDER BY CreationDate DESC;
    END;

GO