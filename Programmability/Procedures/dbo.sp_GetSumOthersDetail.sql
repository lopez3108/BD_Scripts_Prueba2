SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumOthersDetail]
(@CreationDate   DATE,
 @AgencyId       INT,
 @CreatedBy      INT = NULL
)
AS
     BEGIN
         SELECT ISNULL(SUM(od.Usd),0) Suma
         FROM OthersDetails od
              INNER JOIN OthersServices os ON od.OtherServiceId = os.OtherId
         WHERE(CAST(od.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND (od.CreatedBy = @CreatedBy OR @CreatedBy IS NULL)
              AND od.AgencyId = @AgencyId;
     END;
GO