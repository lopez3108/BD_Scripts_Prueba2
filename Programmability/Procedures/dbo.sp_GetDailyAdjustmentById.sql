SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDailyAdjustmentById]
 @DailyAdjustmentId   INT      = NULL
AS
     BEGIN
   
	   SELECT DA.*, U.Name CreatedByName
              FROM DailyAdjustments DA
              LEFT JOIN Daily D ON D.DailyId = DA.DailyId
              INNER JOIN Cashiers C ON C.CashierId = D.CashierId
              INNER JOIN Agencies A ON A.AgencyId = D.AgencyId
		    INNER JOIN Users u On U.UserId = DA.CreatedBy
         WHERE DA.DailyAdjustmentId = @DailyAdjustmentId
     END;
GO