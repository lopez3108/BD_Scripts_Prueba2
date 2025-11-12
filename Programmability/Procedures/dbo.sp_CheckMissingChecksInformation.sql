SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CheckMissingChecksInformation]
(@Date      DATETIME = NULL, 
 @AgencyId  INT      = NULL, 
 @CashierId INT      = NULL, 
 @ProviderTypeCode VARCHAR(5) = NULL,
 @Invalid   BIT OUTPUT
)
AS
    BEGIN
        DECLARE @CountId INT;
        DECLARE @StatusId INT;
        SET @StatusId =
        (
            SELECT DocumentStatus.DocumentStatusId
            FROM DocumentStatus
            WHERE Code = 'C02'
        );--Pending

		DECLARE @lastDayMonth DATETIME = NULL, @checkTypeId INT = NULL

		IF(@Date IS NOT NULL)
		BEGIN

		SET @lastDayMonth = (SELECT EOMONTH ( @Date) )

		END

        SELECT @CountId = COUNT(*)
        FROM
        (
            SELECT c.CheckId
            FROM Checks c
                 LEFT JOIN dbo.Clientes cc ON c.ClientId = cc.ClienteId
                 LEFT JOIN DocumentStatus ds ON ds.DocumentStatusId = c.CheckStatusId
                 LEFT JOIN DocumentStatus dsc ON dsc.DocumentStatusId = cc.ClientStatusId
                 --LEFT JOIN dbo.ReturnedCheck RC ON RC.CheckNumber = C.Number AND RC.MakerId = C.Maker AND RC.ClientId = C.ClientId 
            WHERE(c.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)
                 AND (c.CashierId = @CashierId
                      OR @CashierId IS NULL)
				AND (@Date IS NULL OR 
				((CAST(c.DateCashed as DATE) >= CAST(@Date as DATE) AND 
				CAST(c.DateCashed as DATE) <= CAST(@lastDayMonth as DATE)) AND
				@ProviderTypeCode = (SELECT TOP 1 Code FROM dbo.ProviderTypes p INNER JOIN dbo.ChecksEls ce ON
				ce.ProviderTypeId = p.ProviderTypeId WHERE ce.CheckNumber = c.Number)
				))
                    AND (c.CheckStatusId = @StatusId
                      OR cc.ClientStatusId = @StatusId)
					  AND C.Number NOT IN (SELECT RC.CheckNumber FROM dbo.ReturnedCheck RC WHERE (rc.Account = C.Account AND rc.MakerId = c.Maker AND RC.CheckNumber = c.Number
					  AND rc.AccountBlocked = 0  AND rc.MakerBlocked = 0  AND rc.ClientBlocked = 0))
                      AND C.Account NOT IN (SELECT RC.Account FROM dbo.ReturnedCheck RC WHERE (rc.Account = C.Account AND rc.AccountBlocked = 1))
                      AND C.Maker NOT IN (SELECT RC.MakerId FROM dbo.ReturnedCheck RC WHERE (rc.MakerId = C.Maker AND rc.MakerBlocked = 1))
                      AND C.ClientId NOT IN (SELECT RC.ClientId FROM dbo.ReturnedCheck RC WHERE (rc.ClientId = C.ClientId AND rc.ClientBlocked = 1))
					  ) AS QUERY2;
        IF(@CountId > 0)
            BEGIN
                SET @Invalid = CAST(1 AS BIT);
            END;
            ELSE
            BEGIN
                SET @Invalid = CAST(0 AS BIT);
            END;
    END;

GO