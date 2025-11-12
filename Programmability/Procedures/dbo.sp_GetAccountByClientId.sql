SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Update by jt/10-07-2024 task 5933
-----------------------------------------------------------------------
-- Creation Date : 5 de Julio de 2023
-- Created by Felipe Oquendo 
-- Consulta los acounts por cliente en las tablas:Checks, ReturnedCheck

CREATE PROCEDURE [dbo].[sp_GetAccountByClientId] @ClientId INT
AS


BEGIN
  SELECT DISTINCT
    *
  FROM (SELECT DISTINCT
      c.Account
     ,m.Name Maker
     ,m.Name AS MakerName
     ,m.MakerId
     ,c.Routing
    FROM ChecksEls c
    INNER JOIN Makers m
      ON m.MakerId = c.MakerId
    WHERE c.ClientId = @ClientId
    UNION ALL
    SELECT DISTINCT
      rc.Account
     ,m.Name Maker
     ,m.Name AS MakerName
     ,m.MakerId
     ,rc.Routing
    FROM ReturnedCheck rc
    INNER JOIN Makers m
      ON m.MakerId = rc.MakerId
    WHERE rc.ClientId = @ClientId) AS Account
END;









GO