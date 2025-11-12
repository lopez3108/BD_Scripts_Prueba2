SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePropertyControlXProperty]
(@PropertyControlsXPropertyId INT          = NULL, 
 @PropertyControlId           INT, 
 @PropertiesId                INT          = NULL, 
 @ApartmentId                 INT          = NULL, 
 @Date                        DATETIME, 
 @Note                        VARCHAR(100) = NULL, 
 @Completed                   BIT, 
 @CreationDate                DATETIME, 
 @CreatedBy                   INT, 
 @CurrentDate                 DATETIME = null
)
AS
    BEGIN
        IF(@PropertyControlsXPropertyId IS NULL)
            BEGIN
                INSERT INTO  [dbo].[PropertyControlsXProperty]
                ([PropertyControlId], 
                 [PropertiesId], 
                 [ApartmentsId], 
                 [Date], 
                 [Note], 
                 [Completed], 
                 [CreationDate], 
                 [CreatedBy], 
                 [ValidThrough]
                )
                VALUES
                (@PropertyControlId, 
                 @PropertiesId, 
                 @ApartmentId, 
                 @Date, 
                 @Note, 
                 @Completed, 
                 @CreationDate, 
                 @CreatedBy, 
                 NULL
                );
                SELECT @@IDENTITY;
            END;
            ELSE
            BEGIN
                DECLARE @controlDate DATETIME;
                SET @controlDate =
                (
                    SELECT TOP 1 CreationDate
                    FROM [dbo].[PropertyControlsXProperty]
                    WHERE PropertyControlsXPropertyId = @PropertyControlsXPropertyId
                );
                UPDATE [dbo].[PropertyControlsXProperty]
                  SET 
                      [PropertyControlId] = @PropertyControlId, 
                      [Date] = @Date, 
                      [Note] = @Note, 
                      [Completed] = @Completed
                WHERE PropertyControlsXPropertyId = @PropertyControlsXPropertyId;
                IF(@Completed = 1)
                    BEGIN
                        UPDATE [dbo].[PropertyControlsXProperty]
                          SET 
                              [CompletedDate] = @CurrentDate, 
                              [CompletedBy] = @CreatedBy, 
                              [ValidThrough] = dbo.fn_CalculatePropertyControlValidThrough(@PropertyControlId, @CurrentDate)
                        WHERE PropertyControlsXPropertyId = @PropertyControlsXPropertyId;
                    END;
                SELECT @PropertyControlsXPropertyId;
            END;
    END;
GO