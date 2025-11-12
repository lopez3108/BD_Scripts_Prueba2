SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPlateDesign]
AS
     BEGIN
         
		 SELECT
		 PlateDesignId,
		 Code,
		 [Description]
		 FROM
		 PlateDesign
		 ORDER BY
		 Code ASC





     END;
GO