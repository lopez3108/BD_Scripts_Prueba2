SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetExtraFundAgencyByDateByUsers]
(@Creationdate   DATE = NULL, 
 @AgencyId       INT  = NULL, 
 @UserId         INT  = NULL, 
 @UserAssignedTo INT  = NULL, 
 @IsAdmin        BIT  = NULL
)
AS
    BEGIN
        SELECT e.ExtraFundId, 
               e.CreationDate, 
               e.Usd, 
               e.CreatedBy, 
               e.LastUpdated, 
               e.LastUpdatedBy, 
               c.CashierId CashierIdAssignedTo, 
               c.CashierId CashierIdAssignedToSaved, 
               cc.CashierId CashierIdCreated, 
               e.AssignedTo, 
               e.AgencyId, 
               AcceptNegative = (CASE
                                     WHEN e.AssignedTo = @UserAssignedTo
                                     THEN CAST(0 AS BIT)
                                     ELSE CAST(1 AS BIT)
                                 END), 
               OnlyNegative = (CASE
                                   WHEN e.AssignedTo = @UserAssignedTo
                                   THEN CAST(0 AS BIT)
                                   ELSE CAST(1 AS BIT)
                               END), 
               'Disabled' = (CASE
                                 WHEN e.AssignedTo = @UserAssignedTo
                                 THEN CAST(1 AS BIT)
                                 ELSE CAST(0 AS BIT)
                             END), 
               moneyvalue = (CASE
                                 WHEN e.AssignedTo = @UserAssignedTo
                                 THEN e.Usd
                                 ELSE-e.Usd
                             END),
							 
			   extrafund = (CASE
                                 WHEN e.CashAdmin = 1
                                 THEN 'CASH FOR ADMIN'
                                 ELSE 'EXTRA FUND'
                             END), 
               CAST(1 AS BIT) 'Set', 
               u.Name UserCretedBy, 
               ul.Name UserLastUpdatedBy, 
               ua.Name UserAssignedTo, 
               a.Code + ' - ' + a.Name Agency,
                FORMAT(e.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat ,
                 FORMAT(e.LastUpdated, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedFormat 
        FROM ExtraFund e
             INNER JOIN Agencies a ON a.AgencyId = e.AgencyId
             INNER JOIN Users u ON u.UserId = e.CreatedBy
             INNER JOIN Users ua ON ua.UserId = e.AssignedTo
             LEFT JOIN Users uL ON uL.UserId = e.LastUpdatedBy
             INNER JOIN Cashiers c ON c.UserId = e.AssignedTo
             LEFT JOIN Cashiers cc ON cc.UserId = e.CreatedBy
        WHERE(CAST(e.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
              OR @CreationDate IS NULL)
             AND (e.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)
             AND (e.CreatedBy = @UserId
                  OR @UserId IS NULL)
             AND (e.AssignedTo = @UserAssignedTo
                  OR @UserAssignedTo IS NULL)
             AND ((CAST(@IsAdmin AS BIT) = 1
                   AND (e.CashAdmin = 0
                        AND e.IsCashier = 0)
                   OR (e.CashAdmin = 1
                       AND e.IsCashier = 0))

                  OR (CAST(@IsAdmin AS BIT) = 0
                      AND (e.CashAdmin = 1
                           OR e.IsCashier = 1)));
    END;
GO