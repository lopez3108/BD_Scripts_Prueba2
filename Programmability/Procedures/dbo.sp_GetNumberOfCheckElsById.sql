SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetNumberOfCheckElsById](@ClientId INT, @MakerId INT)
AS
DECLARE @numberCheckEls int;
     BEGIN
      SET @numberCheckEls =  ( SELECT COUNT(*) FROM ChecksEls ce 
        WHERE CE.ClientId = @ClientId AND ce.MakerId = @MakerId )
     END;
     SELECT @numberCheckEls
GO