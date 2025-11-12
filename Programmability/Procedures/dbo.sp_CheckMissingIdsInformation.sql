SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CheckMissingIdsInformation]
(@Date      DATETIME = NULL, 
 @AgencyId  INT      = NULL, 
 @CashierId INT      = NULL, 
 @Invalid   BIT OUTPUT
)
AS
    BEGIN
        DECLARE @CountDaily INT;
        DECLARE @CountId INT;
        DECLARE @StatusId INT;
        SET @StatusId =
        (
            SELECT DocumentStatus.DocumentStatusId
            FROM DocumentStatus
            WHERE Code = 'C02'
        );
        SELECT @CountDaily = COUNT(*)
        FROM
        (
            SELECT D.DailyId
            FROM daily d
            WHERE d.ClosedBy IS NULL
                  AND (d.AgencyId = @AgencyId
                       OR @AgencyId IS NULL)
                  AND (d.CashierId = @CashierId
                       OR @CashierId IS NULL)
                  AND (CAST(@date AS DATE) = CAST(d.CreationDate AS DATE)
                       OR @Date IS NULL)
        ) AS QUERY;
        DECLARE @userId INT;
        SET @userId =
        (
            SELECT TOP 1 UserId
            FROM Cashiers
            WHERE CashierId = @CashierId
        );
        SELECT @CountId = COUNT(*)
        FROM
        (
            SELECT doc.DocumentId
            FROM Documents doc
            WHERE(doc.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)
                 AND (doc.CreatedBy = @userId
                      OR @CashierId IS NULL)
                 AND (doc.DocumentStatusId1 = @StatusId
                      )
        ) AS QUERY2;
        IF(@CountDaily = 1
           AND @CountId > 0)
            BEGIN
                SET @Invalid = CAST(1 AS BIT);
            END;
            ELSE
            BEGIN
                SET @Invalid = CAST(0 AS BIT);
            END;
    END;
GO