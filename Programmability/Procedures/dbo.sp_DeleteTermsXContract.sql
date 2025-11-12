SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteTermsXContract](@TermsXContractId INT = NULL, @ContractId INT = NULL)
AS
     BEGIN
         DELETE FROM [dbo].TermsXContract
         WHERE TermsXContractId = @TermsXContractId OR (@TermsXContractId IS NULL AND ContractId = @ContractId);
     END;
GO