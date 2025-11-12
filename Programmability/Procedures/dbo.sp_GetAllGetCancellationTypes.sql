SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllGetCancellationTypes]
AS
     BEGIN
         SELECT *
         FROM CancellationTypes
         ORDER BY Description;
     END;
GO