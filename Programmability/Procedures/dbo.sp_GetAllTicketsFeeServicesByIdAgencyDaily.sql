SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTicketsFeeServicesByIdAgencyDaily] @AgencyId     INT, 
                                                                   @CreationDate DATE = NULL, 
                                                                   @UserId       INT  = NULL
AS
    BEGIN
        SELECT t.TicketFeeServiceId, 
               ISNULL(t.Usd, 0) Usd, 
              CAST(t.UsedCard AS BIT)UsedCard, 
               t.AgencyId, 
               t.CreationDate, 
               t.CreatedBy, 
               t.Usd moneyvalue, 
               t.Usd Value, 
               'true' Disabled, 
               'true' [Set], 
               CardPaymentFee,
			    CAST(t.UsedCard AS BIT) UsedCardSaved,
				 t.UpdatedOn,
				 t.UpdatedBy,
				 ISNULL(T.Plus, 0 ) Plus,
         usu.Name UpdatedByName,
		 ISNULL(T.Cash, 0) as Cash
        FROM TicketFeeServices t
		LEFT JOIN Users usu ON t.UpdatedBy = usu.UserId
             INNER JOIN Users u ON u.UserId = t.CreatedBy
             INNER JOIN Agencies a ON a.AgencyId = t.AgencyId
        WHERE t.AgencyId = @AgencyId
              AND (CAST(t.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                   OR @CreationDate IS NULL)
              AND (T.CreatedBy = @UserId
                   OR @UserId IS NULL);
    END;
GO