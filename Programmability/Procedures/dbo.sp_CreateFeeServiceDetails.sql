SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-04-11 JF/6449: El número de ticket es único en razón del sistema

CREATE PROCEDURE [dbo].[sp_CreateFeeServiceDetails] 
@TicketFeeServiceDetailsId INT = null,
@TicketFeeServiceId INT,
@TicketNumber VARCHAR(30) ,
@AgencyId INT ,
@Usd DECIMAL(18, 2) ,
@CreatedBy INT ,
@CompletedBy INT ,
@CompletedOn DATETIME,
@LastUpdatedOn DATETIME = NULL,
@LastUpdatedBy INT  = NULL,
 @CashierCommission   DECIMAL (18, 2) = NULL,
 @InvalidTicketNumber          VARCHAR(30) OUTPUT
--@IdCreated      INT OUTPUT

AS
BEGIN
	
IF EXISTS (SELECT top 1 TicketNumber FROM Tickets t WHERE    t.TicketNumber = @TicketNumber)
  BEGIN

SELECT @InvalidTicketNumber = @TicketNumber
  END
ELSE IF EXISTS (SELECT top 1 td.TicketNumber FROM TicketFeeServiceDetails td WHERE  
(TicketFeeServiceDetailsId != @TicketFeeServiceDetailsId OR @TicketFeeServiceDetailsId is null)  
AND td.TicketNumber = @TicketNumber ) 
BEGIN
SELECT @InvalidTicketNumber = @TicketNumber
END   
else


    
  
        IF(@TicketFeeServiceDetailsId IS NULL)
             BEGIN
                 INSERT INTO [dbo].TicketFeeServiceDetails
                 (
                
 TicketFeeServiceId
 ,TicketNumber
 ,AgencyId 
 ,Usd 
 ,CreatedBy 
 ,CompletedBy 
 ,CompletedOn 
 ,LastUpdatedOn 
 ,LastUpdatedBy
 ,CashierCommission 
				 
                 
                 )
                 VALUES
                 (
				
 @TicketFeeServiceId
 ,@TicketNumber
 ,@AgencyId 
 ,@Usd 
 ,@CreatedBy 
 ,@CompletedBy 
 ,@CompletedOn 
 ,@LastUpdatedOn 
 ,@LastUpdatedBy
 ,@CashierCommission 
				 
		  
                 );
--				  SET @IdCreated = @@IDENTITY;
				 
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].TicketFeeServiceDetails
                   SET
                 TicketFeeServiceId = @TicketFeeServiceId
 ,TicketNumber = @TicketNumber
 ,AgencyId = @AgencyId
 ,Usd = @Usd
 ,CreatedBy = @CreatedBy
 ,CompletedBy = @CompletedBy
 ,CompletedOn = @CompletedOn
 ,LastUpdatedOn = @LastUpdatedOn
 ,LastUpdatedBy = @LastUpdatedBy
				 
                  
                 WHERE TicketFeeServiceDetailsId = @TicketFeeServiceDetailsId;
--				  SET @IdCreated = @TicketFeeServiceDetailsId;
				   
         END;
     END;



GO