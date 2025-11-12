SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetComissionsCashier] @StartDate  DATETIME,
                                                @EndingDate DATETIME,
                                                @UserId     INT,
												@AgencyId INT
AS
     BEGIN

	SELECT * FROM [dbo].[FN_GetComissionsCashier] (@StartDate, @EndingDate, @UserId, @AgencyId)


     END;
GO