SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllAdditionalTermsByContractId]
(@ContractId   INT         = NULL

)
AS
     BEGIN
         SELECT tc.* 

  FROM dbo.Contract
             
              INNER JOIN dbo.TermsXContract tc ON tc.ContractId = dbo.Contract.ContractId

         WHERE dbo.Contract.ContractId  = @ContractId
     END;
GO