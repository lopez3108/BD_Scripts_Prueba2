SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashierAgencyFirstLog] (@UserId INT,
@Date DATETIME,
@AgencyId INT = NULL,
@IsAdmin BIT = NULL)
AS

BEGIN



  DECLARE @firstLog BIT
  SET @firstLog = 0



  IF (NOT EXISTS (SELECT
        1
      FROM TimeSheet
      WHERE UserId = @UserId
      AND CAST(LoginDate AS DATE) = CAST(@Date AS DATE)
      AND ((@IsAdmin = 0
      AND AgencyId = @AgencyId)
      OR (@IsAdmin = 1
      AND AgencyId IS NULL AND LogoutDate IS NULL 
      
     
      
      )))  AND NOT EXISTS(SELECT
        1
      FROM TimeSheet
      WHERE @IsAdmin = 1 AND UserId = @UserId
      AND CAST(LoginDate AS DATE) = CAST(@Date AS DATE)
      AND AgencyId IS NOT NULL AND LogoutDate IS NULL  ) 
    )
  BEGIN



    SET @firstLog = 1

  END

  SELECT
    @firstLog

END

GO