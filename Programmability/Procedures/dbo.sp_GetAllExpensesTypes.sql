SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllExpensesTypes]
AS
SET NOCOUNT ON
     BEGIN
         SELECT *
         FROM dbo.ExpensesType;
     END;
GO