SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateTimeSheetAdmins] @UserId INT,
@CreationDate DATETIME = NULL
AS

DECLARE @timeSheetNotClosed bit = 0

IF (EXISTS (SELECT * FROM TimeSheet ts  WHERE UserId = @UserId
  AND CAST(ts.LoginDate AS DATE) = CAST(@CreationDate AS DATE)
  AND AgencyId IS NULL AND  ts.LogoutDate IS NULL )

)

BEGIN
  UPDATE dbo.TimeSheet 
  SET LogoutDate = @CreationDate
  WHERE UserId = @UserId
  AND CAST(LoginDate AS DATE) = CAST(@CreationDate AS DATE)
  AND AgencyId IS NULL AND  LogoutDate IS NULL;

SET @timeSheetNotClosed = 1

END;

SELECT
    @timeSheetNotClosed 
GO