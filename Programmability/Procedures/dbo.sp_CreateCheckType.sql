SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateCheckType] @CheckTypeId INT            = NULL, 
                                           @Description VARCHAR(50), 
                                           @DefaultFee  DECIMAL(18, 2), 
                                           @Active      BIT, 
										   @CategoryCheckTypeId int,
										   @MaxCheckAmount DECIMAL (18,2)
AS
    BEGIN
        IF(@CheckTypeId IS NULL)
            BEGIN
                INSERT INTO [dbo].[CheckTypes]
                ([Description], 
                 [DefaultFee], 
                 [Active],
				CategoryCheckTypeId,
				 MaxCheckAmount
                )
                VALUES
                (@Description, 
                 @DefaultFee, 
                 @Active,
				@CategoryCheckTypeId,
				 @MaxCheckAmount
                );
                SELECT @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE [dbo].[CheckTypes]
                  SET 
                      Description = @Description, 
                      DefaultFee = @DefaultFee, 
                      Active = @Active,
					  CategoryCheckTypeId= @CategoryCheckTypeId,
					  MaxCheckAmount= @MaxCheckAmount
                WHERE CheckTypeId = @CheckTypeId;
                SELECT @CheckTypeId;
        END;
    END;
GO