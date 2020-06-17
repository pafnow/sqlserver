SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ZZ0_Spy](
	[SpyId] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[HostName] [varchar](255) NOT NULL,
	[AppName] [varchar](255) NOT NULL,
	[TableName] [varchar](255) NOT NULL,
	[SqlAction] [varchar](1) NOT NULL,
	[CountRec] [int] NOT NULL,
	[PrimaryKey] [varchar](max) NOT NULL,
	[Changes] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ZZ1_Spy] PRIMARY KEY CLUSTERED 
(
	[SpyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ZZ0_Spy] ADD  CONSTRAINT [DF_ZZ1_Spy_Date]  DEFAULT (getdate()) FOR [Date]
GO

ALTER TABLE [dbo].[ZZ0_Spy] ADD  CONSTRAINT [DF_ZZ1_Spy_UserName]  DEFAULT (suser_name()) FOR [UserName]
GO

ALTER TABLE [dbo].[ZZ0_Spy] ADD  CONSTRAINT [DF_ZZ1_Spy_HostName]  DEFAULT (host_name()) FOR [HostName]
GO

ALTER TABLE [dbo].[ZZ0_Spy] ADD  CONSTRAINT [DF_ZZ1_Spy_AppName]  DEFAULT (app_name()) FOR [AppName]
GO