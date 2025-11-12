SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ChangeTitleStatus]
(@TitleId              INT         = NULL, 
 @ProcessStatusId      INT         = NULL, 
 @PackageNumber        VARCHAR(15) = NULL, 
 @Dunbar               DATETIME    = NULL, 
 @DeliveredPackageDate DATETIME    = NULL, 
 @UpdatedBy            INT         = NULL, 
 @DatePendingState     DATETIME    = NULL, 
 @DatePending          DATETIME    = NULL, 
 @DateReceived         DATETIME    = NULL, 
 @DateCompleted        DATETIME    = NULL, 
 @DatePendingStateBy   INT         = NULL, 
 @DatePendingBy        INT         = NULL, 
 @DateReceivedBy       INT         = NULL, 
 @DateCompletedBy      INT         = NULL
)
AS
    BEGIN
        UPDATE [dbo].[Titles]
          SET 
              ProcessStatusId = @ProcessStatusId, 
              PackageNumber = @PackageNumber, 
              Dunbar = @Dunbar, 
              DeliveredPackageDate = @DeliveredPackageDate, 
              UpdatedBy = @UpdatedBy, 
              DatePendingState = @DatePendingState, 
              DatePending = @DatePending, 
              DateReceived = @DateReceived, 
              DateCompleted = @DateCompleted, 
              DatePendingStateBy = @DatePendingStateBy, 
              DatePendingBy = @DatePendingBy, 
              DateReceivedBy = @DateReceivedBy, 
              DateCompletedBy = @DateCompletedBy
        WHERE TitleId = @TitleId;
    END;
GO