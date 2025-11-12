SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: Johan
--LASTUPDATEDON:23-10-2023
--CAMBIOS EN 5446 se crea sp para validar informacion pendiente por proveedor.
CREATE PROCEDURE [dbo].[sp_GetProviderPendingInfoCommissionPayment] (
@ProviderTypeCode VARCHAR(4))
AS
  DECLARE @CountPendingInfo INT;
  BEGIN

--    IF (@ProviderTypeCode = 'C03'
--      OR @ProviderTypeCode = 'C04')--CHECKS
--    BEGIN
--
--
--      DECLARE @StatusId INT;
--      SET @StatusId = (SELECT
--          DocumentStatus.DocumentStatusId
--        FROM DocumentStatus
--        WHERE Code = 'C02');--Pending
--
--      SELECT
--        @CountPendingInfo = COUNT(*)
--      FROM (SELECT
--          c.CheckId
--        FROM Checks c
--        LEFT JOIN dbo.Clientes cc
--          ON c.ClientId = cc.ClienteId
--        LEFT JOIN DocumentStatus ds
--          ON ds.DocumentStatusId = c.CheckStatusId
--        LEFT JOIN DocumentStatus dsc
--          ON dsc.DocumentStatusId = cc.ClientStatusId
--        --LEFT JOIN dbo.ReturnedCheck RC ON RC.CheckNumber = C.Number AND RC.MakerId = C.Maker AND RC.ClientId = C.ClientId 
--        WHERE (c.CheckStatusId = @StatusId
--        OR cc.ClientStatusId = @StatusId)
--        AND c.Number NOT IN (SELECT
--            RC.CheckNumber
--          FROM dbo.ReturnedCheck RC
--          WHERE (RC.Account = c.Account
--          AND RC.MakerId = c.Maker
--          AND RC.CheckNumber = c.Number
--          AND RC.AccountBlocked = 0
--          AND RC.MakerBlocked = 0
--          AND RC.ClientBlocked = 0))
--        AND c.Account NOT IN (SELECT
--            RC.Account
--          FROM dbo.ReturnedCheck RC
--          WHERE (RC.Account = c.Account
--          AND RC.AccountBlocked = 1))
--        AND c.Maker NOT IN (SELECT
--            RC.MakerId
--          FROM dbo.ReturnedCheck RC
--          WHERE (RC.MakerId = c.Maker
--          AND RC.MakerBlocked = 1))
--        AND c.ClientId NOT IN (SELECT
--            RC.ClientId
--          FROM dbo.ReturnedCheck RC
--          WHERE (RC.ClientId = c.ClientId
--          AND RC.ClientBlocked = 1))) AS QUERY2;
--
--    END;
--    ELSE
--
--
--
--    --  IF (@ProviderTypeCode = 'C06') -- CANCELLATIONS (YA NO PUEDEN QUEDAR PENDING)
--    --  BEGIN
--    --SELECT CS.Description FROM Cancellations c 
--    --INNER JOIN CancellationStatus cs ON c.InitialStatusId = cs.CancellationStatusId
--    --WHERE CS.CODE = 'C03'
--    --   
--    --
--    --  END;
--    --  ELSE
----    IF (@ProviderTypeCode = 'C08') -- RETURNED CHECKS
----    BEGIN
----      SET @CountPendingInfo = (SELECT
----          COUNT(*)
----        FROM ReturnedCheck rc
----        INNER JOIN ReturnStatus rs
----          ON rs.ReturnStatusId = rc.StatusId
----        WHERE rs.Code = 'C03')
----
----
----    END;
----    ELSE
----    IF (@ProviderTypeCode = 'C13') --PERSONAL LOANS (LENDIFTY)
----    BEGIN
----      SET @CountPendingInfo = (SELECT
----          COUNT(*)
----        FROM Lendify l
----        INNER JOIN LendifyStatus ls
----          ON l.LendifyStatusId = ls.LendifyStatusId
----        WHERE ls.Code = 'C01')
----
----    END;
----    ELSE
--    IF (@ProviderTypeCode = 'C05')   --TITLES AND PLATE
--    BEGIN
--      SET @CountPendingInfo = (SELECT
--          COUNT(*)
--        FROM Titles t
--        INNER JOIN ProcessStatus ps
--          ON t.ProcessStatusId = ps.ProcessStatusId
--        WHERE ps.Code = 'C00')
--
--
--    END;
--    ELSE
--    IF (@ProviderTypeCode = 'C09') -- TRP
--    BEGIN
--      SET @CountPendingInfo = (SELECT
--          COUNT(*)
--        FROM TRP trp
--        WHERE ((trp.ClientName = ''
--        OR trp.ClientName IS NULL)
--        OR (trp.PermitNumber = ''
--        OR trp.PermitNumber IS NULL)
--        OR (trp.PermitTypeId <= 0
--        OR trp.PermitTypeId IS NULL)))
--
--    END;
--    ELSE
--    IF (@ProviderTypeCode = 'C24')    -- TICKETS
--    BEGIN
--      SET @CountPendingInfo = (SELECT
--          COUNT(*)
--        FROM Tickets t
--        INNER JOIN TicketStatus ts
--          ON t.TicketStatusId = ts.TicketStatusId
--        WHERE ts.Code = 'C03')
--    END;
    SELECT
      ISNULL(@CountPendingInfo, 0 ) AS Pendings
  END;






GO