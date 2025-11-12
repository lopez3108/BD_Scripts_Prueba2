SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllFiltersRegisteredMacs]
AS
     BEGIN
         SELECT Mac , Description, ComputerBrand
         FROM RegisteredMacs
         
     END;
GO