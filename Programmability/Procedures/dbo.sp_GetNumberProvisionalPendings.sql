SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberProvisionalPendings]
(@UserId AS    INT, 
 @AgencyId AS  INT = NULL, 
 @IsManager AS BIT = NULL,
  @IsCashier AS BIT = NULL
)
AS
    BEGIN
        SELECT COUNT(*) Pendings
        FROM dbo.ProvisionalReceipts P
             INNER JOIN Cashiers C ON C.CashierId = P.CreatedBy
        WHERE (P.Completed = 0

              AND ((@IsCashier = 1
                    AND (P.AgencyId = @AgencyId)
                   )
                   OR (@IsManager = 1
                       AND P.AgencyId IN
        (
            SELECT AgencyId
            FROM AgenciesxUser
            WHERE UserId = @UserId
        )))) or (@IsCashier = 0 and @IsManager = 0  and P.Completed = 0);
    END;
GO