SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--UPDATE Felipe oquendo
--date 29-11-2023 task 5494

CREATE PROCEDURE [dbo].[sp_CreateTimesheetComplete]
(@TimeSheetId   INT      = NULL, 
 @UserId        INT, 
 @LoginDate     DATETIME, 
 @LogoutDate    DATETIME, 
 @LastUpdatedOn DATETIME = NULL, 
 @LastUpdatedBy INT      = NULL, 
 @AgencyId      INT      = NULL,
 @EstimatedDepartureTime TIME = NULL,
 @ApprovedOn DATETIME = NULL, 
 @ApprovedBy INT      = NULL,
 @StatusId INT      = NULL,
 @PreApproved bit = NULL
)
AS
    BEGIN
        IF(@TimeSheetId IS NULL)
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.Payrolls
                    WHERE CAST(@LoginDate AS DATE) BETWEEN CAST(dbo.Payrolls.FromDate AS DATE) AND CAST(dbo.Payrolls.ToDate AS DATE)
                          AND dbo.Payrolls.UserId = @UserId
                )
                    BEGIN
                        SELECT-1;
                    END;
                    ELSE
                    BEGIN
                        INSERT INTO [dbo].[TimeSheet]
                        ([UserId], 
                         [LoginDate], 
                         LogoutDate, 
                         LastUpdatedOn, 
                         LastUpdatedBy, 
                         [AgencyId]
                        )
                        VALUES
                        (@UserId, 
                         @LoginDate, 
                         @LogoutDate, 
                         @LastUpdatedOn, 
                         @LastUpdatedBy, 
                         @AgencyId
                        );
                        SELECT @@IDENTITY;
                    END;
            END;
            ELSE
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.Payrolls
                    WHERE CAST(@LoginDate AS DATE) BETWEEN CAST(dbo.Payrolls.FromDate AS DATE) AND CAST(dbo.Payrolls.ToDate AS DATE)
                          AND dbo.Payrolls.UserId = @UserId
                )
                    BEGIN
                        SELECT-1;
                    END;
                    ELSE
                    BEGIN
                        UPDATE [dbo].[TimeSheet]
                          SET 
                              LoginDate = @LoginDate, 
                              LogoutDate = @LogoutDate, 
                              LastUpdatedOn = @LastUpdatedOn, 
                              LastUpdatedBy = @LastUpdatedBy,
							                ApprovedBy = @ApprovedBy,
							                ApprovedOn = @ApprovedOn,
                              PreApproved = @PreApproved,
							   EstimatedDepartureTime = @EstimatedDepartureTime,
							   	  StatusId = @StatusId
                        WHERE TimeSheetId = @TimeSheetId;
                        SELECT @TimeSheetId;
                    END;
            END;
    END;
GO