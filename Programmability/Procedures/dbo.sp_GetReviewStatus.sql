SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_GetReviewStatus]
AS
    BEGIN 
	SELECT *
	FROM ReviewDaysStatus 
	
    END;
GO