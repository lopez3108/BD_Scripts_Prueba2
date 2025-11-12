SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetInstructionChangeById]
                 @InstructionChangeId int
AS
  SELECT *
 
  FROM dbo.InstructionChange ic
       INNER JOIN
       dbo.InstructionChangeStatus ics
       ON ic.StatusId = ics.StatusId
  WHERE ic.InstructionChangeId = @InstructionChangeId
GO