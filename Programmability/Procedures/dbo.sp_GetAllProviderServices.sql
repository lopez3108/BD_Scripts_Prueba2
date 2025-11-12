SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllProviderServices]
AS
     BEGIN
         SELECT * FROM ProvidersServices ps
     END;
GO