SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		Juan Felipe Oquendo López
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_SaveOrderOfficeSuppliesDetails] @OrderOfficeSuppliesDetailsId    INT      = NULL, 
                                                          @OrderOfficeSupplieId            INT, 
                                                          @OfficeSupplieId                 INT, 
                                                          @Quantity                        INT, 
                                                          @Status                          INT, 
                                                          @AgencyId                        INT, 
                                                          --@Note                         VARCHAR(150) = NULL, 
                                                          @SentBy                          INT      = NULL, 
                                                          @SentOn                          DATETIME = NULL, 
                                                          @CompletedBy                     INT      = NULL, 
                                                          @CompletedOn                     DATETIME = NULL, 
                                                          @RefundDate                      DATETIME = NULL, 
                                                          @CompletedRefundBy               INT      = NULL, 
                                                          @IsSavedNotes                    BIT      = NULL, 
                                                          @OldOrderOfficeSuppliesDetailsId INT      = NULL, 
                                                          @IdCreated                       INT OUTPUT
AS

    BEGIN
        IF(@OrderOfficeSuppliesDetailsId IS NULL)
            BEGIN
                INSERT INTO [dbo].OrderOfficeSuppliesDetails
                ([OrderOfficeSupplieId], 
                 [OfficeSupplieId], 
                 [Quantity], 
                 STATUS, 
                 AgencyId, 
                 --Note, 
                 SentBy, 
                 SentOn, 
                 CompletedBy, 
                 CompletedOn, 
                 RefundDate, 
                 CompletedRefundBy
                )
                VALUES
                (@OrderOfficeSupplieId, 
                 @OfficeSupplieId, 
                 @Quantity, 
                 @Status, 
                 @AgencyId, 
                 --@Note, 
                 @SentBy, 
                 @SentOn, 
                 @CompletedBy, 
                 @CompletedOn, 
                 @RefundDate, 
                 @CompletedRefundBy
                );
                SET @IdCreated = @@IDENTITY;
				if(@IsSavedNotes = 1)
                BEGIN
                    INSERT INTO  NotesXOrderOfficeSupply
                    (Note, 
                     OrderOfficeSupplieId, 
                     CreationDate, 
                     CreatedBy
                    )
                           SELECT Note, 
                                  @IdCreated, 
                                  CreationDate, 
                                  CreatedBy
                           FROM NotesXOrderOfficeSupply
                           WHERE OrderOfficeSupplieId = @OldOrderOfficeSuppliesDetailsId;
                END;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].OrderOfficeSuppliesDetails
                  SET 
                      [OrderOfficeSupplieId] = @OrderOfficeSupplieId, 
                      [OfficeSupplieId] = @OfficeSupplieId, 
                      [Quantity] = @Quantity, 
                      STATUS = @Status, 
                      AgencyId = @AgencyId, 
                      --Note = @Note, 
                      SentBy = @SentBy, 
                      SentOn = @SentOn, 
                      CompletedBy = @CompletedBy, 
                      CompletedOn = @CompletedOn, 
                      --RefundDate = @RefundDate, 
                      CompletedRefundBy = @CompletedRefundBy
                WHERE OrderOfficeSuppliesDetailsId = @OrderOfficeSuppliesDetailsId;
                SET @IdCreated = @OrderOfficeSuppliesDetailsId;
            END;
    END;
GO