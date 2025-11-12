SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-07-22- DJ/6652: Proceso automatico revision Tickets

CREATE FUNCTION [dbo].[FN_ListToTableString](@List VARCHAR(MAX))
RETURNS @ParsedList TABLE(item VARCHAR(max))
AS
     BEGIN
         DECLARE @item VARCHAR(MAX), @Pos INT;
         SET @List = LTRIM(RTRIM(@List))+',';
         SET @Pos = CHARINDEX(',', @List, 1);
         WHILE @Pos > 0
             BEGIN
                 SET @item = LTRIM(RTRIM(LEFT(@List, @Pos-1)));
                 IF @item <> ''
                     BEGIN
                         INSERT INTO @ParsedList(item)
                     VALUES(CAST(@item AS VARCHAR(max)));
                 END;
                 SET @List = RIGHT(@List, LEN(@List) - @Pos);
                 SET @Pos = CHARINDEX(',', @List, 1);
             END;
         RETURN;
     END;
GO