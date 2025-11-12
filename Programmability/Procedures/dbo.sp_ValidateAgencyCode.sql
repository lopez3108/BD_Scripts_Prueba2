SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: FELIPE
--CREATEDON: 25-03-23
--USO: Validar si el numero de transacion  está repetido  
CREATE PROCEDURE [dbo].[sp_ValidateAgencyCode] (@AgencyCode  varchar(10),@AgencyId INT = NULL)
 AS
  BEGIN
   SELECT TOP 1  a.Code FROM Agencies a
     WHERE ( a.AgencyId != @AgencyId OR @AgencyId IS NULL ) AND @AgencyCode = a.Code
  END


GO