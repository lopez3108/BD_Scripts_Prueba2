SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProviderOfficeSupplies] 
AS
    BEGIN
        SELECT *
	
        FROM [dbo].ProvidersOfficeSupplies p
       
    END;
GO