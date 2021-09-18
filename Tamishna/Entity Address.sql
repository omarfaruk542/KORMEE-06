IF EXISTS (SELECT * FROM sys.objects where object_id = OBJECT_ID(N'Organization.EntityAddressInfo'))
BEGIN
	DROP TABLE [Organization].[EntityAddressInfo]
END
GO
CREATE TABLE [Organization].[EntityAddressInfo](
	[EntityID] [int] NOT NULL,
	[EntityName] [varchar](100) NOT NULL,
	[Address] [varchar](250) NULL,
	[EntityNameLocal] [nvarchar](250) NULL,
	[AddressLocal] [nvarchar](250) NULL,
	[Logo] [image] NULL
 CONSTRAINT [PKCEntityAddressInformationEntityID] PRIMARY KEY CLUSTERED 
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT INTO [Organization].[EntityAddressInfo](EntityID,EntityName)
SELECT EntityID,EntityName FROM Organization.EntityInfo
GO
UPDATE [Organization].[EntityAddressInfo] SET Address = 'Plot # 247, Bhadam, Tongi, Gazipur'
UPDATE [Organization].[EntityAddressInfo] SET AddressLocal = N'২৪৭, ভাদাম, নিশাতনগর, টঙ্গী, গাজীপুর-১৭১১, বাংলাদেশ',
EntityNameLocal = N'তামিশনা ফ্যাশন ওয়্যার লিঃ'
WHERE EntityName = 'Tamishna Fashion Wear Ltd.'
GO
SELECT * FROM [Organization].[EntityAddressInfo]

