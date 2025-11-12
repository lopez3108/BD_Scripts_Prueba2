SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTypeOfInternationalTopUps]
AS
     BEGIN
         SELECT* FROM dbo.TypeOfInternationalTopUps
        
     END;
GO