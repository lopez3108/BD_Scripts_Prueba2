SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by Juan Felipe Oquendo lopez..
--17-Mayo-2023  Task 5067 Icono Check Fraud Alerts ..

-- UPDATE : Felipe oquendo   date : 24-11-2023   task: 5457

CREATE PROCEDURE [dbo].[sp_GetAllCheckFraudAlerts]
( 
 
 @TransactionDate   DATE        = NULL,
 @ClientName        VARCHAR(50) = NULL,  
 @Maker             VARCHAR(80) = NULL, 
 @NumberRouting     VARCHAR(15) = NULL,
 @Account           VARCHAR(50) = NULL,
 @CheckNumber       VARCHAR(50) = NULL,
 @Telephone VARCHAR(20)= NULL


)
AS
    BEGIN           
    
          SELECT fa.FraudId,               
                 FORMAT(fa.TransactionDate, 'MM-dd-yyyy', 'en-US')	TransactionDateFormat,
                
                 fa.ClientName,          
                 fa.Maker,
                 fa.CheckType,
                 FA.MakerAddress,
                 fa.NumberRouting,
                 fa.Account,
                 fa.CheckNumber,
                 fa.Telephone,
                 fa.ClientAddress,
                 fa.DOB,
                 FORMAT(fa.DOB, 'MM-dd-yyyy', 'en-US')	DOBFormat,                 
                 fa.Country,
                 fa.IdentificacionNumber AS NumberId,
                 fa.CreationDate,
                 FORMAT(fa.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')	CreationDateFormat,
                 fa.CreatedName,
                 fa.LastUpdatedOn,
                 FORMAT(fa.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')	LastUpdatedOnFormat,
                 fa.LastUpdatedName,
                 UPPER(ux.State)AS State,
                 fa.FileNumber,
                 fa.MakerAddress,
                 fa.IsNotFraud,
                 (SELECT TOP 1 IsSafe FROM CheckFraudExceptions as ce WHERE ce.Account = fa.Account AND ce.Maker = fa.Maker
                )AS IsAccountSafe,
                (SELECT TOP 1 CheckFraudExceptionId FROM CheckFraudExceptions as ce WHERE ce.Account = fa.Account AND ce.Maker = fa.Maker
                )AS CheckFraudExceptionId
--				  CASE
--				 WHEN ce.CheckFraudExceptionId IS NOT NULL AND CAST(ce.IsSafe as BIT)  = CAST(1 as BIT) THEN 
--				 CAST(1 as BIT) ELSE
--				 CAST(0 as BIT) END AS IsAccountSafe,
--				 CASE
--				 WHEN ce.CheckFraudExceptionId IS NOT NULL THEN 
--				 ce.CheckFraudExceptionId ELSE
--				 NULL END AS CheckFraudExceptionId
          FROM FraudAlert fa     
		   LEFT JOIN UrlsXState ux ON fa.[StateAbreviation ] = ux.StateAbre
          WHERE (CAST(fa.TransactionDate AS DATE) = CAST(@TransactionDate AS DATE)
              OR @TransactionDate IS NULL)
                
                    AND (fa.ClientName LIKE '%' + @ClientName + '%'
                  OR @ClientName IS NULL)    
                  
                  AND ((SELECT
      [dbo].[Removespecialcharatersinstring](UPPER(fa.Maker)))
  = (SELECT
      [dbo].[Removespecialcharatersinstring](UPPER(@Maker)))
  OR @Maker IS NULL) --5120 task se deben buscar las coincidencias sin tener en cuetna caracteres especiales ni espacios 
                    
--                    AND (fa.Maker LIKE '%' +  @Maker + '%'
--                  OR  @Maker IS NULL)        
                    AND (fa.NumberRouting LIKE '%' + @NumberRouting + '%' 
                    OR @NumberRouting IS NULL )
                    AND (fa.Account =  @Account 
                  OR  @Account IS NULL)
                    AND (fa.CheckNumber LIKE '%' +  @CheckNumber + '%'
                  OR  @CheckNumber IS NULL) 
AND (fa.Telephone = @Telephone OR @Telephone is null)
                  ORDER BY fa.TransactionDate DESC;
          
      
  
    END;












GO