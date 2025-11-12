SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      sa
-- Create date: 10/12/2024 3:12 p. m.
-- Database:    developing
-- Description: task 6423 Insurance - Add nuevo campo insurance
-- =============================================
-- 2025-01-24 JF/6308: INSURANCE - No actualiza Last update by  &  Last Update On en la grid

CREATE PROCEDURE [dbo].[sp_CompleteInsuranceMonthlyPayment] 
@InsuranceMonthlyPaymentId INT = NULL,
@TransactionId VARCHAR(36) = NULL,
@StatusCode VARCHAR(4),
@LastUpdatedOn DATETIME,
@LastUpdatedBy INT,
@IdCreated INT OUTPUT
AS

BEGIN

  DECLARE  @TransactionIdExist INT,@monthlyPaymentStatusId INT;    
         

 SET @monthlyPaymentStatusId = (SELECT TOP 1
        MonthlyPaymentStatusId
      FROM dbo.MonthlyPaymentStatus mps
      WHERE mps.Code = @StatusCode)


SET @TransactionIdExist = (
    SELECT COUNT(1)
    FROM InsurancePolicy i
    WHERE i.TransactionId = @TransactionId
);

IF @TransactionIdExist > 0 BEGIN 
SET @IdCreated = -3

  SELECT
      @IdCreated	
END

ELSE 
      
      BEGIN

        UPDATE [dbo].[InsuranceMonthlyPayment]
        
        SET  TransactionId = @TransactionId 
            ,MonthlyPaymentStatusId = @monthlyPaymentStatusId  
            ,LastUpdatedBy = @LastUpdatedBy
            ,LastUpdatedOn = @LastUpdatedOn   
                    
        WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId
     
        SET @IdCreated = @InsuranceMonthlyPaymentId

      END

END



GO