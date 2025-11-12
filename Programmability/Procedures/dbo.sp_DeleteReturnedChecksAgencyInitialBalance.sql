SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteReturnedChecksAgencyInitialBalance] 
AS
     BEGIN
         
DELETE FROM [dbo].[ReturnedChecksxAgencyInitialBalances]

SELECT 1







     END;
GO