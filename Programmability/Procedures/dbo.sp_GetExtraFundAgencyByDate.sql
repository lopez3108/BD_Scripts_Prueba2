SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetExtraFundAgencyByDate]
(@Creationdate   DATE = NULL, 
 @AgencyId       INT  = NULL, 
 @UserId         INT  = NULL, 
 @UserAssignedTo INT  = NULL
)
AS
    BEGIN
        SELECT e.ExtraFundId, 
               e.CreationDate, 
               e.USD, 
               e.Reason,
               e.CreatedBy, 
               e.LastUpdated, 
               e.LastUpdatedBy, 
               e.AssignedTo, 
               e.AssignedTo AssignedToSaved, 
               c.CashierId CashierIdAssignedTo, 
               c.CashierId CashierIdAssignedToSaved, 
               cc.CashierId CashierIdCreated, 
               e.AgencyId,
               e.completed,
               u1.Name AS CompletedBy,
               e.CompletedOn,
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
                             --WHEN e.AssignedTo = @UserAssignedTo OR  d.DailyId  > 0
                                 WHEN e.AssignedTo = @UserAssignedTo
                                      AND e.CashAdmin = 0
                                 THEN CAST(1 AS BIT)
                                 WHEN(e.CreatedBy = @UserId
                                      AND e.CashAdmin = 1)
                                 THEN CAST(1 AS BIT)
                                 ELSE CAST(0 AS BIT)
                             END), 
               moneyvalue = (CASE
                                 WHEN e.AssignedTo = @UserAssignedTo
                                      AND e.CashAdmin = 0
                                 THEN e.USD
                                 ELSE-e.USD
                             END), 
               Value = (CASE
                            WHEN e.AssignedTo = @UserAssignedTo
                                 AND e.CashAdmin = 0
                            THEN e.USD
                            ELSE-e.USD
                        END), 
               UsdSaved = (CASE
                               WHEN e.AssignedTo = @UserAssignedTo
                                    AND e.CashAdmin = 0
                               THEN e.USD
                               ELSE-e.USD
                           END), 
               CAST(1 AS BIT) 'Set', 
               CAST(1 AS BIT) NeedEvaluate, 
               UPPER(u.Name) UserCretedBy, 
               UPPER(uLu.Name) UserLastUpdatedBy, 
               UPPER(uL.Name) UserAssignedTo, 
               a.Name Agency, 
               e.CashAdmin, 
               e.IsCashier

        --,
        --            d.DailyId
        FROM ExtraFund e
             INNER JOIN Agencies a ON a.AgencyId = e.AgencyId
             INNER JOIN Users u ON u.UserId = e.CreatedBy
             LEFT JOIN Users u1 ON u1.UserId = e.CompletedBy
             --LEFT JOIN Daily d ON d.CashierId = e.AssignedTo AND CAST(d.CreationDate AS DATE)   = CAST(@CreationDate AS DATE) 
             -- LEFT JOIN Cashiers cl ON cl.CashierId = e.LastUpdatedBy
             LEFT JOIN Users uL ON uL.UserId = e.AssignedTo
             LEFT JOIN Users uLu ON uLu.UserId = e.LastUpdatedBy
             left JOIN Cashiers c ON c.UserId = e.AssignedTo
             LEFT JOIN Cashiers cc ON cc.UserId = e.CreatedBy
        --LEFT JOIN Daily d ON CAST(d.CreationDate AS DATE) = CAST(d.CreationDate AS DATE)
        --                     AND (D.AgencyId = @AgencyId
        --                          OR @AgencyId IS NULL)
        --WHERE(CAST(e.CreationDate AS DATE) = CAST(@Creationdate AS DATE)
        --           OR @Creationdate IS NULL)
        --          AND (e.AgencyId = @AgencyId
        --               OR @AgencyId IS NULL)
        --          AND ((u.UserId = @UserId
        --                OR @UserId IS NULL)
        --               OR (uL.UserId = @UserAssignedTo
        --                   OR @UserAssignedTo IS NULL));

        WHERE(CAST(e.CreationDate AS DATE) = CAST(@Creationdate AS DATE)
              OR @Creationdate IS NULL)
             AND (e.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)
             AND (((e.CashAdmin = 0 AND uL.UserId = @UserAssignedTo  ---recbidos que no sean cash admin
                   OR @UserAssignedTo IS NULL )
                  )
             or ((u.UserId = @UserId ---- hechos cashier to cashier
                  OR @UserId IS NULL)
                 AND (e.AssignedTo <> @UserAssignedTo
                      OR @UserAssignedTo IS NULL)
                 AND e.IsCashier = 1)
             OR ((u.UserId = @UserId ---cash for admin hechos
                  OR @UserId IS NULL)
                 AND e.CashAdmin = 1))
				 ;
    END;

GO