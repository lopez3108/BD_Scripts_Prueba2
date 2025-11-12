SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 24/06/2024 12:20 p. m.
-- Database:    devtest
-- Description: task 5896  Ajustes reporte OTHER SERVICES
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetAllOthersActivesServices]
AS
BEGIN
  SELECT
    *
  FROM OthersServices
--
--  WHERE Active = 1
  ORDER BY Name;
END;
GO