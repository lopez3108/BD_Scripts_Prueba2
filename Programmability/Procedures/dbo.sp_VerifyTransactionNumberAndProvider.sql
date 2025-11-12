SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATEDBY: FELIPE
--CREATEDON: 25-03-23
--USO: Validar si el numero de transacion  está repetido  
CREATE PROCEDURE [dbo].[sp_VerifyTransactionNumberAndProvider] (@ProviderId  INt,@TransactionNumber  varchar(30))
 AS
  BEGIN
   SELECT top 1 gn.TransactionNumber,p.Name AS ProviderName  FROM GeneralNotes gn
   INNER JOIN Providers p ON p.ProviderId = gn.ProviderId
     WHERE @ProviderId = GN.ProviderId AND @TransactionNumber = gn.TransactionNumber
  END

GO