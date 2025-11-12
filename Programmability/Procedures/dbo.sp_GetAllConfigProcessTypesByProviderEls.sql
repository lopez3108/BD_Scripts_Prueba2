SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllConfigProcessTypesByProviderEls] @ProviderElsId INT
AS
     BEGIN
         SELECT p.ProcessTypeId,
                ISNULL(c.ProviderElsId, 0) ProviderElsId,
                p.Code,
                p.Description,
                p.ProcessAuto,
                p.[Order],
                ISNULL(c.ConfigurationFeesXProviderElsXProcessId, 0) ConfigurationFeesXProviderElsXProcessId,
                ISNULL(c.Fee1Default, 0) Fee1Default,
                ISNULL(c.FeeELS, 0) FeeELS
         FROM ProcessTypes P
              LEFT JOIN ConfigFeesXProviderElsXProcess C ON C.ProcessTypeId = P.ProcessTypeId
         WHERE C.ProviderElsId = @ProviderElsId OR C.ProviderElsId IS NULL AND ProcessAuto = 1
         ORDER BY [Order];
     END;
GO