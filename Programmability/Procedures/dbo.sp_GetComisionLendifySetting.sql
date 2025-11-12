SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetComisionLendifySetting]
AS
     BEGIN
        
		SELECT TOP 1 ISNULL(LendifyCompany, 0) as LendifyCompany ,*  FROM ComissionSettings

     END;

GO