SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllGeneralNotes] @FromDate             DATE          = NULL, 
                                              @ToDate               DATE          = NULL, 
                                              @AgencyId             INT           = NULL, 
                                              @ProviderId           INT           = NULL, 
                                              @TransactionNumber    VARCHAR(30)   = NULL, 
                                              @ClientName           VARCHAR(150)  = NULL, 
                                              @DescriptionStatus    VARCHAR(2000) = NULL, 
                                              @GeneralNotesStatusId INT           = NULL
AS
    BEGIN
        SELECT gn.GeneralNoteId, 
               UPPER(LEFT(gn.Description, 18)) AS DescriptionC, 
               UPPER(gn.Description )AS Description, 
               gn.GeneralNotesStatusId, 
               gs.Code AS CodeStatus, 
               gs.Code AS CodeStatusSaved, 
               UPPER(gs.Description) AS DescriptionStatus, 
               pt.code AS Code, 
               gn.ProviderId, 
               UPPER(p.Name) AS ProviderName, 
               gn.ClientName, 
               gn.ClientTelephone, 
			   gn.ClientTelephone as ClientTelephoneSaved, 
               gn.TransactionNumber, 
               gn.OtherDescription, 
			   gn.FileGeneralNotes,
               gn.CreationDate, 
			   FORMAT(gn.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               gn.CreatedBy, 
               gn.AgencyId, 
               UPPER(a.Code + ' - ' + a.Name) AgencyName, 
               gn.ClosedOn AS ClosedOn, 
			    FORMAT(gn.ClosedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  ClosedOnFormat,
               UPPER(dbo.Users.Name) AS CreatedByName,
			    ISNULL(gn.TelIsCheck , CAST(0 AS BIT)) TelIsCheck,
               --CASE
               --    WHEN gs.Code = 'C02'
               --    THEN UPPER(ucreate.Name)
               --    ELSE NULL
               --END AS ClosedByName

               UPPER(ucreate.Name) AS ClosedByName
        FROM [dbo].GeneralNotes gn
             INNER JOIN Agencies A ON a.AgencyId = gn.AgencyId
             INNER JOIN GeneralnotesStatus gs ON gs.GeneralNotesStatusId = gn.GeneralNotesStatusId
             INNER JOIN Providers p ON p.ProviderId = gn.ProviderId
             INNER JOIN Providertypes pt ON pt.ProviderTypeId = p.ProviderTypeId
             INNER JOIN dbo.Users ON dbo.Users.UserId = gn.CreatedBy
             LEFT JOIN Users ucreate ON ucreate.UserId = gn.ClosedBy
             LEFT JOIN dbo.Cashiers ON dbo.Cashiers.UserId = dbo.Users.UserId
        WHERE(gn.AgencyId = @AgencyId
              OR @AgencyId IS NULL)
             AND (gn.GeneralNotesStatusId = @GeneralNotesStatusId
                  OR @GeneralNotesStatusId IS NULL)
             AND (gn.ProviderId = @ProviderId
                  OR @ProviderId IS NULL)
             AND (gn.TransactionNumber LIKE '%'+@TransactionNumber+'%' 
                  OR @TransactionNumber IS NULL)
             AND (gn.ClientName LIKE '%'+@ClientName+'%' 
                  OR @ClientName IS NULL)
             AND ((CAST(gn.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   OR @FromDate IS NULL)
                  AND (CAST(gn.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
                  OR @ToDate IS NULL)
        ORDER BY CreationDate DESC;
    END;
GO