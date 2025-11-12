SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveScheduleRanges]
(@ScheduleConfigurationId INT      = NULL, 
 @ToTime                  TIME, 
 @FromTime                TIME, 
 @CreatedBy               INT, 
 @UpdatedBy               INT, 
 @UpdatedOn               DATETIME, 
 @CreationDate           DATETIME, 
 @AgencyId                INT, 
 @CodDay                  varchar(3)
)
AS
    BEGIN
        IF(@ScheduleConfigurationId IS NULL)
            BEGIN
                INSERT INTO [dbo].[ConfigurationScheduleRangesAgencies]
                (ToTime, 
                 FromTime, 
                 CreatedBy, 
                 UpdatedBy, 
                 UpdatedOn, 
                 CreationDate, 
                 AgencyId, 
                 CodDay
                )
                VALUES
                (@ToTime, 
                 @FromTime, 
                 @Createdby, 
                 @UpdatedBy, 
                 @UpdatedOn, 
                 @CreationDate, 
                 @AgencyId, 
                 @CodDay
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ConfigurationScheduleRangesAgencies]
                  SET 
                      ToTime = @ToTime, 
                      FromTime = @FromTime, 
                      CreatedBy = @CreatedBy, 
                      UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn, 
                      CreationDate = @CreationDate, 
                      AgencyId = @AgencyId, 
                      CodDay = @CodDay
                WHERE ScheduleConfigurationId = @ScheduleConfigurationId;
            END;
    END;
GO