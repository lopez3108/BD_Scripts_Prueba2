SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      sa
-- Create date: 10/07/2024 4:40 p. m.
-- Database:    copiaDevtest
-- Description: task 5918 Restringir serial numbers unique para los vehicle services returns
-- =============================================


--EXEC [dbo].[sp_GetAllCashiers] null
CREATE PROCEDURE [dbo].[sp_GetAllSerialsXReturn]   @ReturnsELSId INT
AS
     BEGIN
      select *,SerialNumber AS SerialNumberSaved from SerialsXReturn
	  where ReturnsELSId = @ReturnsELSId

     END;
GO