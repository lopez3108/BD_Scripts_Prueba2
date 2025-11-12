SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberViewsOfTraining] @TrainingId     INT = NULL
                                             
AS
BEGIN
    SELECT COUNT(vu.TrainingId ) NumberViews FROM  TrainingXUsers vu 
    WHERE vu.TrainingId = @TrainingId
     END;
GO