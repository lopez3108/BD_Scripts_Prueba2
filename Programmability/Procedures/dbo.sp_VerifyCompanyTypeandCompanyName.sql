SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: FELIPE
--CREATEDON: 25-03-23
--USO: Validar si el numero de transacion  está repetido  
CREATE PROCEDURE [dbo].[sp_VerifyCompanyTypeandCompanyName] ( @CompanyType INT, @CompanyName  varchar(250),@CompanyId INT = NULL )
 AS
  BEGIN
   SELECT top 1 c.CompanyName,ct.CompanyTypeName  FROM Companies c
   INNER JOIN CompanyType ct ON ct.CompanyType = c.CompanyType
     WHERE  ( c.CompanyId != @CompanyId OR @CompanyId  IS NULL ) AND @CompanyType = c.CompanyType AND @CompanyName = c.CompanyName
  END

GO