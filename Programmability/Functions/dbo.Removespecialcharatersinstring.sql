SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   function  [dbo].[Removespecialcharatersinstring](@string varchar(250))
returns varchar(250)
AS
BEGIN
 DECLARE @strvalue varchar(250) = '%[^0-9A-Z]%'
 WHILE PATINDEX(@strvalue,@string)>0
                 SET @string = Stuff(@string,PATINDEX(@strvalue,@string),1,'')
                 Return @string
 END
GO