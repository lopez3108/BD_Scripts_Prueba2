SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateZipCode]
 (
      @ZipCode varchar(10),
	  @City varchar(20),
	  @State varchar(20),
	  @County varchar(30) = null
    )
AS 

BEGIN

INSERT INTO [dbo].[ZipCodes]
           ([ZipCode]
           ,[City]
           ,[State]
           ,[County])
     VALUES
           (@ZipCode
           ,@City
           ,@State
           ,@County)

	END

GO