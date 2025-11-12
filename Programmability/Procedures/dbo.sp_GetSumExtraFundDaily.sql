SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumExtraFundDaily]
(@Creationdate   DATE = NULL, 
 @AgencyId       INT  = NULL, 
 @UserId         INT  = NULL, 
 @UserAssignedTo INT  = NULL
)
AS
    BEGIN
        SELECT ISNULL(
        (
            SELECT ISNULL(SUM(e.Usd), 0) Suma
            FROM ExtraFund e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE(CAST(e.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                  OR @CreationDate IS NULL)
                 AND (e.AgencyId = @AgencyId
                      OR @AgencyId IS NULL)
                 --AND (e.AssignedTo = @UserAssignedTo
                 --     AND e.CashAdmin = 0
                 --     OR @UserAssignedTo IS NULL)
				   AND ((e.AssignedTo = @UserAssignedTo ---recbidos
                   OR @UserAssignedTo IS NULL)
                  AND e.CashAdmin = 0
				  --AND e.IsCashier = 1
				  )
        ) -
        (
            SELECT ISNULL(SUM(e.Usd), 0) Resta
            FROM ExtraFund e
                 INNER JOIN Users u ON u.UserId = e.CreatedBy
            WHERE(CAST(e.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                  OR @CreationDate IS NULL)
                 AND (e.AgencyId = @AgencyId
                      OR @AgencyId IS NULL)
					    and (((u.UserId = @UserId ---- hechos cashier to cashier
                  OR @UserId IS NULL)
                 AND (e.AssignedTo <> @UserAssignedTo
                      OR @UserAssignedTo IS NULL)
                 AND e.IsCashier = 1)
             OR ((u.UserId = @UserId ---cash for admin hechos
                  OR @UserId IS NULL)
                 AND e.CashAdmin = 1))



          --       AND ((e.CreatedBy = @UserId
          --             OR @UserId IS NULL)
					     ----AND ((e.AssignedTo = @UserAssignedTo and E.CashAdmin =0 and e.IsCashier = 0 ) 
          --            AND ((e.AssignedTo <> @UserAssignedTo and e.IsCashier = 1 )
          --                 OR E.CashAdmin = 1 ))
        ) - (
            SELECT ISNULL(SUM((e.Usd * -1)), 0) Suma
            FROM dbo.ExtraFundAgencyToAgency e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE(CAST(e.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
                 AND (e.FromAgencyId = @AgencyId)
				   AND ((e.CreatedBy = @UserId) ---made
				  )
        ) + (
            SELECT ISNULL(SUM((e.Usd * -1)), 0) Suma
            FROM dbo.ExtraFundAgencyToAgency e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE(CAST(e.AcceptedDate AS DATE) = CAST(@CreationDate AS DATE))
                 AND (e.ToAgencyId = @AgencyId)
				   AND ((e.AcceptedBy = @UserId) ---received
				  )
        ), 0) AS TotalExtraFund;
    END;

 
GO