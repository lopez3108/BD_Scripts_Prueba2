SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllFinancingStatus]
AS
     BEGIN
         SELECT *                
         FROM FinancingStatus
         ORDER BY Description;
     END;
GO