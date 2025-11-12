SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPetList] 
AS
    BEGIN
        SELECT *
        FROM [dbo].Pets P
        
    END;
GO