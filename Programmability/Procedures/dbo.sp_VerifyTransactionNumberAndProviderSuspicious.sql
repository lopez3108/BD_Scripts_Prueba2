SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: FELIPE
--CREATEDON: 27-03-23
--USO: Validar si el numero de transacion  está repetido  
CREATE PROCEDURE [dbo].[sp_VerifyTransactionNumberAndProviderSuspicious] (@ProviderId  INt,@TransactionNumber  varchar(30))
 AS
  BEGIN
   SELECT top 1 sa.TransactionNumber,p.Name AS ProviderName  FROM SuspiciousActivity sa
   INNER JOIN Providers p ON p.ProviderId = sa.ProviderId
     WHERE @ProviderId = sa.ProviderId AND @TransactionNumber = sa.TransactionNumber
  END


GO