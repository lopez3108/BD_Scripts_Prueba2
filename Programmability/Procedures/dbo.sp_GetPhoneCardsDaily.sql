SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPhoneCardsDaily]
(@Creationdate DATE = NULL, 
 @AgencyId     INT, 
 @UserId       INT  = NULL
)
AS
    BEGIN
        SELECT ISNULL(PhoneCardId, 0) PhoneCardId, 
               Quantity, 
               PhoneCardsUsd, 
               CreatedBy, 
               CreationDate, 
               AgencyId, 
               Quantity NumberTransactions, 
			   Quantity QuantitySaved,
			   PhoneCardsUsd PhoneCardsUsdSaved,
               ISNULL(PhoneCardsUsd, 0) Total,
			    v.UpdatedOn,
         usu.Name UpdatedByName
        FROM PhoneCards v
		LEFT JOIN Users usu ON v.UpdatedBy = usu.UserId
        WHERE(CAST(v.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
              OR @CreationDate IS NULL)
             AND v.AgencyId = @AgencyId
             AND v.CreatedBy = @UserId;
    END;
GO