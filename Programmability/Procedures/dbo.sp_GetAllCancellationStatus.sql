SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCancellationStatus]
AS
     BEGIN
         SELECT *                
         FROM CancellationStatus
         ORDER BY Description;
     END;


GO