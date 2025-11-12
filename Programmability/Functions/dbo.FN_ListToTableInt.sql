SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FN_ListToTableInt](@List VARCHAR(MAX))
RETURNS @ParsedList TABLE(item INT)
AS
     BEGIN
         DECLARE @item VARCHAR(800), @Pos INT;
         SET @List = LTRIM(RTRIM(@List))+',';
         SET @Pos = CHARINDEX(',', @List, 1);
         WHILE @Pos > 0
             BEGIN
                 SET @item = LTRIM(RTRIM(LEFT(@List, @Pos-1)));
                 IF @item <> ''
                     BEGIN
                         INSERT INTO @ParsedList(item)
                     VALUES(CAST(@item AS INT));
                 END;
                 SET @List = RIGHT(@List, LEN(@List) - @Pos);
                 SET @Pos = CHARINDEX(',', @List, 1);
             END;
         RETURN;
     END;
GO