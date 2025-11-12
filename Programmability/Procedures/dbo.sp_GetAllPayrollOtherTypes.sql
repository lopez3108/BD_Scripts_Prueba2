SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPayrollOtherTypes]
AS
     BEGIN
         SELECT *
         FROM PayrollOtherTypes
         ORDER BY Description;
     END;
GO