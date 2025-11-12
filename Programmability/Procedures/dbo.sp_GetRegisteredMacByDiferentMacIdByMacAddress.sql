SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetRegisteredMacByDiferentMacIdByMacAddress] @Mac             VARCHAR(30) = NULL,
                                                                       @RegisteredMacId INT         = NULL
AS
     BEGIN
         SELECT *
         FROM RegisteredMacs r
         WHERE(REPLACE(r.Mac, '-', '') = REPLACE(@Mac, '-', ''))
              AND (r.RegisteredMacId <> @RegisteredMacId
                   OR @RegisteredMacId IS NULL OR  @RegisteredMacId <= 0);
     END;
GO