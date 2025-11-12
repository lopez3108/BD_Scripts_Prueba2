SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConfigProcessTypesByProviderElsByProcessTypeId] @ProviderElsId INT,
                                                                               @ProcessTypeId INT
AS
     BEGIN
         SELECT ISNULL(c.ConfigurationFeesXProviderElsXProcessId, 0) ConfigurationFeesXProviderElsXProcessId,
                ProcessTypeId,
                ProviderElsId,
                ISNULL(c.Fee1Default, 0) Fee1Default,
                ISNULL(c.FeeELS, 0) FeeELS
         FROM ConfigFeesXProviderElsXProcess c
         WHERE C.ProviderElsId = @ProviderElsId
               AND C.ProcessTypeId = @ProcessTypeId;
     END;
GO