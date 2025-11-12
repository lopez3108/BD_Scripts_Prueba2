SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveOrdersOfficeSupplies]
(@OrderOfficeSupplieId INT      = NULL, 
 @OrderDate            DATETIME, 
 @OrderOfficeStatusId  INT, 
 @CreatedBy            INT, 
 --@LastUpdated          DATETIME = NULL, 
 --@LastUpdatedBy        INT      = NULL, 
 @SentOn               DATETIME = NULL, 
 @SentBy               INT      = NULL, 
 @ConpletedOn          DATETIME = NULL, 
 @CompletedBy          INT      = NULL, 
 @IdCreated            INT OUTPUT
)
AS
    BEGIN
        IF(@OrderOfficeSupplieId IS NULL)
            BEGIN
                INSERT INTO [dbo].[OrdersOfficeSupplies]
                ([OrderDate], 
                
                 [CreatedBy], 
                 --[LastUpdated], 
                 --[LastUpdatedBy], 
                 [SentOn], 
                 [SentBy], 
                 [ConpletedOn], 
                 [CompletedBy]
                )
                VALUES
                (@OrderDate, 
                
                 @CreatedBy, 
                 --@LastUpdated, 
                 --@LastUpdatedBy, 
                 @SentOn, 
                 @SentBy, 
                 @ConpletedOn, 
                 @CompletedBy
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[OrdersOfficeSupplies]
                  SET 
                      [OrderDate] = @OrderDate, 
                     
                      [CreatedBy] = @CreatedBy, 
                      --[LastUpdated] = @LastUpdated, 
                      --[LastUpdatedBy] = @LastUpdatedBy, 
                      [SentOn] = @SentOn, 
                      [SentBy] = @SentBy, 
                      [ConpletedOn] = @ConpletedOn, 
                      [CompletedBy] = @CompletedBy
                WHERE OrderOfficeSupplieId = @OrderOfficeSupplieId;
                SET @IdCreated = @OrderOfficeSupplieId;
            END;
    END;
GO