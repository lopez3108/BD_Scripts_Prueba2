SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCheckListResult](@Id int,
@Section VARCHAR(10))
AS
     BEGIN
         SELECT *,
         cast(1 AS bit) AS selected
         FROM CheckListResult C
WHERE (@Section = 'TRP' AND C.TRPId = @Id) OR (@Section = 'TITLES' AND C.TitleId = @Id)
     END;


GO