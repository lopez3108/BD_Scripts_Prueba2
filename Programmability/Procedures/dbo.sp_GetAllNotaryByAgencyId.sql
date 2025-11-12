SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotaryByAgencyId] @AgencyId     INT, 
                                                  @CreationDate DATE = NULL, 
                                                  @UserId       INT
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT n.NotaryId, 
               n.Quantity, 
               n.Usd , 
			   n.Quantity QuantitySaved, 
               n.Usd 'ValueSaved', 
               n.AgencyId, 
               n.CreatedBy, 
               n.CreationDate, 
               n.AgencyId, 
			    n.UpdatedOn,
         usu.Name UpdatedByName,
               n.Usd 'moneyvalue', 
               n.Usd 'Value', 
               'false' 'AcceptNegative', 
               'true' 'Valid', 
               'true' 'Set'
        FROM Notary n
             INNER JOIN Agencies a ON n.AgencyId = a.AgencyId
             INNER JOIN Users u ON n.CreatedBy = u.UserId
			 LEFT JOIN Users usu ON n.UpdatedBy = usu.UserId
        WHERE n.AgencyId = @AgencyId
              AND (CAST(n.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                   OR @CreationDate IS NULL)
              AND CreatedBy = @UserId;
    END;
GO