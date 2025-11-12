SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATEDBY: JOHAN
--CREATEDON: 2-03-23
--USO: PROPIEDADES CON CONTRACTOS ACTIOS
CREATE PROCEDURE [dbo].[sp_GetAllContractsByStatus]
                                           @Status      VARCHAR(5)        = NULL,
                                            @CurrentDate DATETIME = NULL
                                         
AS
    BEGIN

       SELECT DISTINCT
            
              
                   
               dbo.Properties.PropertiesId,       
               dbo.Properties.Name AS PropertyName, 
               dbo.Properties.Address AS PropertyAddress
      
        FROM dbo.Properties     
        INNER JOIN Apartments a ON a.PropertiesId = Properties.PropertiesId   

        WHERE a.ApartmentsId IN (SELECT c.ApartmentId FROM dbo.Contract c
         INNER JOIN dbo.ContractStatus ON dbo.ContractStatus.ContractStatusId = c.STATUS
        where
         (@Status IS NULL OR (@Status = 'C01' AND c.Status = (SELECT TOP 1 ContractStatusId FROM ContractStatus WHERE Code = 'C01')) OR
@Status IS NULL OR (@Status = 'C02' AND c.Status = (SELECT TOP 1 ContractStatusId FROM ContractStatus WHERE Code = 'C02')) 
--OR
--@Status IS NULL OR (@Status = 'C00' AND [dbo].[fn_GetContractIsExpired](c.ContractId, @CurrentDate) = CAST(1 as BIT))
        
        
        ))

             
           


             
    END;

GO