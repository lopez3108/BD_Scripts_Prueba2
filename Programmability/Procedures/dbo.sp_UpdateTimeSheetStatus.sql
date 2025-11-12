SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--UPDATE Felipe oquendo
--date 29-11-2023 task 5494

CREATE PROCEDURE [dbo].[sp_UpdateTimeSheetStatus] @TimeSheetId INT, 
                                                 @StatusId    INT,
												                 @ApprovedOn datetime = null,
												                  @ApprovedBy int = null,
                                           @PreApproved bit = NULL
AS
    BEGIN
        UPDATE dbo.TimeSheet
          SET 
              StatusId = @StatusId,
			  ApprovedOn= @ApprovedOn,
			  ApprovedBy = @ApprovedBy,
        PreApproved = @PreApproved
        WHERE TimeSheetId = @TimeSheetId;
    END;
GO