

use Ucontinental 

---validación de existencia de tablas 

/*1*/	IF OBJECT_ID('[grupo6].[Proveedor]') IS NOT NULL DROP TABLE [grupo6].[Proveedor];
/*2*/	IF OBJECT_ID('[grupo6].[claseproducto]') IS NOT NULL DROP TABLE [grupo6].[claseproducto];
/*3*/	IF OBJECT_ID('[grupo6].[productos]') IS NOT NULL DROP TABLE [grupo6].[productos];
/*4*/	IF OBJECT_ID('[grupo6].[clientes]') IS NOT NULL DROP TABLE [grupo6].[clientes];	
/*5*/	IF OBJECT_ID('[grupo6].[DireccionCliente]') IS NOT NULL DROP TABLE [grupo6].[DireccionCliente];
/*6*/	IF OBJECT_ID('[grupo6].[DireccionCodificada]') IS NOT NULL DROP TABLE [grupo6].[DireccionCodificada];
/*7*/	IF OBJECT_ID('[grupo6].[Pedidos]') IS NOT NULL DROP TABLE [grupo6].[Pedidos];
/*8*/	IF OBJECT_ID('[grupo6].[DetallePedidos]') IS NOT NULL DROP TABLE [grupo6].[DetallePedidos];
/*9*/	IF OBJECT_ID('[grupo6].[Departamento]') IS NOT NULL DROP TABLE [grupo6].[Departamento];
/*10*/	IF OBJECT_ID('[grupo6].[Provincia]') IS NOT NULL DROP TABLE [grupo6].[Provincia];
/*11*/	IF OBJECT_ID('[grupo6].[Distrito]') IS NOT NULL DROP TABLE [grupo6].[Distrito];
/*12*/	IF OBJECT_ID('[grupo6].[Pais]') IS NOT NULL DROP TABLE [grupo6].[Pais];
/*13*/	IF OBJECT_ID('[grupo6].[MedioPago]') IS NOT NULL DROP TABLE [grupo6].[MedioPago];

----select * from sysobjects where xtype='U' order by name 

------creacion de tablas 

CREATE TABLE [grupo6].[ClaseProducto](
	[ClaseProducto_Id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[ClaseProducto] [nvarchar](300) NULL,
	[Estado] [int] NULL)

GO

CREATE TABLE [grupo6].[Clientes](
	[ClienteID] [int] IDENTITY(1,1) NOT NULL Primary key,
	[NombreEmpresa] [varchar](50) NULL,
	[Contacto] [varchar](50) NULL,
	[CorreoElectronico] [varchar](50) NULL,
	[Telefono] [varchar](15) NULL)

GO

CREATE TABLE [grupo6].[departamento](
	[departamento_Id] [int]  IDENTITY(1,1) NOT NULL Primary key,
	[NombreDepartamento] [nvarchar](100) NULL,
	[Pais_id] [int] NULL,
	[estado] [int] NULL)

GO

CREATE TABLE [grupo6].[DetallesPedido](
	[DetalleID] [int] IDENTITY(1,1) NOT NULL Primary key,
	[PedidoID] [int] NULL,
	[ProductoID] [int] NULL,
	[Cantidad] [int] NULL,
	[Precio] [float] NULL,
	[ImporteVenta] [float] NULL,
	[Descuento] [float] NULL,
	[Impuesto] [float] NULL)

GO

CREATE TABLE [grupo6].[DireccionCliente](
	[IdDireccionCliente] IDENTITY(1,1) NOT NULL Primary key,
	[ClienteId] [int] NULL,
	[DireccionCodificadaId] [int] NULL,
	[EsPrincipal] [int] NULL,
	[Estado] [int] NULL)

GO 

CREATE TABLE [grupo6].[DireccionCodificada](
	[direccioncodificada_id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[distrito_id] [int] NULL,
	[referencia] [nvarchar](500) NULL,
	[estado] [int] NULL,
	[TipoVia_id] [int] NULL,
	[Via_id] [int] NULL,
	[nro] [nvarchar](10) NULL,
	[interior] [nvarchar](10) NULL)

GO 

CREATE TABLE [grupo6].[distrito](
	[Distrito_id] [int]  IDENTITY(1,1) NOT NULL Primary key,
	[NombreDistrito] [nvarchar](100) NULL,
	[CodigoPostal] [nvarchar](100) NULL,
	[Provincia_id] [int] NULL,
	[Estado] [int] NULL)

GO

CREATE TABLE [grupo6].[EstadoPedido](
	[EstadoPedido_Id] [int]  IDENTITY(1,1) NOT NULL Primary key,
	[EstadoPedido_Descripcion] [nvarchar](200) NULL,
	[Estado] [int] NULL)

GO


CREATE TABLE [grupo6].[MedioPago](
	[MedioPago_id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[MedioPago] [nvarchar](100) NULL,
	[estado] [int] NULL)

GO

CREATE TABLE [grupo6].[pais](
	[pais_id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[NombrePais] [nvarchar](100) NULL,
	[estado] [int] NULL)

GO

CREATE TABLE [grupo6].[Pedidos](
	[PedidoID] [int] IDENTITY(1,1) NOT NULL Primary key,
	[FechaPedido] [date] NULL,
	[ClienteID] [int] NULL,
	[direccioncodificada_id] [int] NULL,
	[MedioPago_id] [int] NULL,
	[EstadoPedido_Id] [int] NULL,
	[IdDireccionCliente] [int] NULL)

GO
CREATE TABLE [grupo6].[Productos](
	[ProductoID] [int] IDENTITY(1,1) NOT NULL Primary key,
	[NombreProducto] [varchar](50) NULL,
	[Precio] [decimal](10, 2) NULL,
	[Stock] [int] NULL,
	[ClaseProducto_Id] [int] NULL,
	[Proveedor_Id] [int] NULL)

GO

CREATE TABLE [grupo6].[Proveedor](
	[Proveedor_Id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[Ruc] [nvarchar](12) NULL,
	[Nombre_Proveedor] [nvarchar](300) NULL,
	[Estado] [int] NULL)

GO

CREATE TABLE [grupo6].[provincia](
	[Provincia_Id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[NombreProvincia] [nvarchar](100) NULL,
	[Departamento_id] [int] NULL,
	[estado] [int] NULL)

GO
CREATE TABLE [grupo6].[TipoVia](
	[TipoVia_id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[tipoVia_Descripcion] [nvarchar](200) NULL,
	[Estado] [int] NULL)

GO

CREATE TABLE [grupo6].[Via](
	[Via_Id] [int] IDENTITY(1,1) NOT NULL Primary key,
	[via_Descripcion] [nvarchar](200) NULL,
	[Estado] [int] NULL)
GO


---creacion de referencias 

ALTER TABLE [grupo6].[departamento]  ADD CONSTRAINT [FK_departamento_pais] FOREIGN KEY([Pais_id])
REFERENCES [grupo6].[pais] ([pais_id])
GO

ALTER TABLE [grupo6].[DetallesPedido]  WITH CHECK ADD FOREIGN KEY([PedidoID])
REFERENCES [grupo6].[Pedidos] ([PedidoID])
GO
ALTER TABLE [grupo6].[DetallesPedido]  WITH CHECK ADD FOREIGN KEY([ProductoID])
REFERENCES [grupo6].[Productos] ([ProductoID])
GO
ALTER TABLE [grupo6].[DireccionCliente]  WITH CHECK ADD  CONSTRAINT [FK_cliente] FOREIGN KEY([ClienteId])
REFERENCES [grupo6].[Clientes] ([ClienteID])
GO
ALTER TABLE [grupo6].[DireccionCliente] CHECK CONSTRAINT [FK_cliente]
GO
ALTER TABLE [grupo6].[DireccionCliente]  WITH CHECK ADD  CONSTRAINT [FK_direccioncodificada] FOREIGN KEY([DireccionCodificadaId])
REFERENCES [grupo6].[DireccionCodificada] ([direccioncodificada_id])
GO
ALTER TABLE [grupo6].[DireccionCliente] CHECK CONSTRAINT [FK_direccioncodificada]
GO
ALTER TABLE [grupo6].[DireccionCodificada]  WITH CHECK ADD  CONSTRAINT [FK_DireccionCodificada_distrito] FOREIGN KEY([distrito_id])
REFERENCES [grupo6].[distrito] ([Distrito_id])
GO
ALTER TABLE [grupo6].[DireccionCodificada] CHECK CONSTRAINT [FK_DireccionCodificada_distrito]
GO
ALTER TABLE [grupo6].[DireccionCodificada]  WITH CHECK ADD  CONSTRAINT [FK_tipovia] FOREIGN KEY([TipoVia_id])
REFERENCES [grupo6].[TipoVia] ([TipoVia_id])
GO
ALTER TABLE [grupo6].[DireccionCodificada] CHECK CONSTRAINT [FK_tipovia]
GO
ALTER TABLE [grupo6].[DireccionCodificada]  WITH CHECK ADD  CONSTRAINT [FK_via] FOREIGN KEY([Via_id])
REFERENCES [grupo6].[Via] ([Via_Id])
GO
ALTER TABLE [grupo6].[DireccionCodificada] CHECK CONSTRAINT [FK_via]
GO
ALTER TABLE [grupo6].[distrito]  WITH CHECK ADD  CONSTRAINT [FK_distrito_provincia] FOREIGN KEY([Provincia_id])
REFERENCES [grupo6].[provincia] ([Provincia_Id])
GO
ALTER TABLE [grupo6].[distrito] CHECK CONSTRAINT [FK_distrito_provincia]
GO
ALTER TABLE [grupo6].[Pedidos]  WITH CHECK ADD FOREIGN KEY([ClienteID])
REFERENCES [grupo6].[Clientes] ([ClienteID])
GO
ALTER TABLE [grupo6].[Pedidos]  WITH CHECK ADD  CONSTRAINT [FK_estadopedido] FOREIGN KEY([EstadoPedido_Id])
REFERENCES [grupo6].[EstadoPedido] ([EstadoPedido_Id])
GO
ALTER TABLE [grupo6].[Pedidos] CHECK CONSTRAINT [FK_estadopedido]
GO
ALTER TABLE [grupo6].[Pedidos]  WITH CHECK ADD  CONSTRAINT [FK_Pedidos_direccioncliente] FOREIGN KEY([IdDireccionCliente])
REFERENCES [grupo6].[DireccionCliente] ([IdDireccionCliente])
GO
ALTER TABLE [grupo6].[Pedidos] CHECK CONSTRAINT [FK_Pedidos_direccioncliente]
GO
ALTER TABLE [grupo6].[Pedidos]  WITH CHECK ADD  CONSTRAINT [FK_Pedidos_mediopago] FOREIGN KEY([MedioPago_id])
REFERENCES [grupo6].[MedioPago] ([MedioPago_id])
GO
ALTER TABLE [grupo6].[Pedidos] CHECK CONSTRAINT [FK_Pedidos_mediopago]
GO
ALTER TABLE [grupo6].[Productos]  WITH CHECK ADD  CONSTRAINT [FK_Productos_claseproducto] FOREIGN KEY([ClaseProducto_Id])
REFERENCES [grupo6].[ClaseProducto] ([ClaseProducto_Id])
GO
ALTER TABLE [grupo6].[Productos] CHECK CONSTRAINT [FK_Productos_claseproducto]
GO
ALTER TABLE [grupo6].[Productos]  WITH CHECK ADD  CONSTRAINT [FK_Productos_proveedor] FOREIGN KEY([Proveedor_Id])
REFERENCES [grupo6].[Proveedor] ([Proveedor_Id])
GO
ALTER TABLE [grupo6].[Productos] CHECK CONSTRAINT [FK_Productos_proveedor]
GO
ALTER TABLE [grupo6].[provincia]  WITH CHECK ADD  CONSTRAINT [FK_provincia_departamento] FOREIGN KEY([Departamento_id])
REFERENCES [grupo6].[departamento] ([departamento_Id])
GO
ALTER TABLE [grupo6].[provincia] CHECK CONSTRAINT [FK_provincia_departamento]
GO
