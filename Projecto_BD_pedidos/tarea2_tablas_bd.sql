select * from grupo6.productos 

select * from grupo6.detallespedido

drop table grupo6.Proveedor 

create table grupo6.Proveedor 
(
Proveedor_Id int identity (1,1) primary key,
Ruc nvarchar(12) ,
Nombre_Proveedor nvarchar(300),
Estado int 
)

drop table grupo6.ClaseProducto 

create table grupo6.ClaseProducto 
(
ClaseProducto_Id int identity (1,1) primary key ,
ClaseProducto nvarchar (300) ,
Estado int 
)

alter table grupo6.Productos
add  ClaseProducto_Id int 

alter table grupo6.Productos
add Proveedor_Id int 

ALTER TABLE grupo6.Productos
   ADD CONSTRAINT FK_Productos_claseproducto FOREIGN KEY (ClaseProducto_Id)
      REFERENCES grupo6.ClaseProducto (ClaseProducto_Id)

alter table grupo6.productos
    ADD CONSTRAINT FK_Productos_proveedor FOREIGN KEY (Proveedor_Id)
      REFERENCES grupo6.proveedor (Proveedor_Id)

	  select * from grupo6.pedidos

alter table [grupo6].[Pedidos]
add direccioncodificada_id int 


create table grupo6.DireccionCodificada
(
direccioncodificada_id int identity(1,1) primary key ,
distrito_id int,
referencia nvarchar (500),
estado int 
)

create table grupo6.distrito 
(
Distrito_id int identity(1,1) primary key ,
NombreDistrito nvarchar(100) ,
CodigoPostal nvarchar (100) ,
Provincia_id int,
Estado int
)

create table grupo6.provincia 
(
Provincia_Id int identity(1,1) primary key ,
NombreProvincia nvarchar(100),
Departamento_id int,
estado int 
)

create table grupo6.departamento 
(
departamento_Id int identity(1,1) primary key ,
NombreDepartamento nvarchar(100),
Pais_id int,
estado int 
)

create table grupo6.pais
(
pais_id int identity(1,1) primary key ,
NombrePais nvarchar(100),
estado int 
)

alter table [grupo6].[Pedidos]
add direccioncodificada_id int 


ALTER TABLE [grupo6].[Pedidos]
   ADD CONSTRAINT FK_Pedidos_direccion FOREIGN KEY (direccioncodificada_id )
      REFERENCES grupo6.DireccionCodificada (direccioncodificada_id )


ALTER TABLE [grupo6].DireccionCodificada
   ADD CONSTRAINT FK_DireccionCodificada_distrito FOREIGN KEY (distrito_id )
      REFERENCES grupo6.distrito (distrito_id )

ALTER TABLE [grupo6].distrito
   ADD CONSTRAINT FK_distrito_provincia FOREIGN KEY (provincia_id )
      REFERENCES grupo6.provincia (provincia_id )


ALTER TABLE [grupo6].provincia
   ADD CONSTRAINT FK_provincia_departamento FOREIGN KEY (departamento_id )
      REFERENCES grupo6.departamento (departamento_id )


ALTER TABLE [grupo6].departamento 
   ADD CONSTRAINT FK_departamento_pais FOREIGN KEY (pais_id )
      REFERENCES grupo6.pais (pais_id )

create table [grupo6].MedioPago
(
MedioPago_id int identity(1,1) primary key ,
MedioPago nvarchar(100) ,
estado int 
)


alter table [grupo6].[Pedidos]
add MedioPago_id int 



ALTER TABLE [grupo6].[Pedidos]
   ADD CONSTRAINT FK_Pedidos_mediopago FOREIGN KEY (MedioPago_id )
      REFERENCES grupo6.MedioPago (MedioPago_id )


	  --alter table [grupo6].[DireccionCodificada]
	  --add Receptor 

	  
create table grupo6.TipoVia
(
TipoVia_id int identity (1,1) primary key ,
tipoVia_Descripcion nvarchar(200) ,
Estado int 
)

create table grupo6.Via
(
Via_Id int identity (1,1) primary key ,
via_Descripcion nvarchar(200) ,
Estado int 
)


alter table grupo6.direccioncodificada
add TipoVia_id int

alter table grupo6.direccioncodificada
add Via_id int

alter table grupo6.direccioncodificada
add nro nvarchar (10)

alter table grupo6.direccioncodificada
add interior nvarchar (10) 

ALTER TABLE [grupo6].direccioncodificada
   ADD CONSTRAINT FK_tipovia FOREIGN KEY (TipoVia_id )
      REFERENCES grupo6.TipoVia (TipoVia_id )

ALTER TABLE [grupo6].direccioncodificada
   ADD CONSTRAINT FK_via FOREIGN KEY (Via_id )
      REFERENCES grupo6.Via (Via_id )

create table [grupo6].[EstadoPedido]
(
EstadoPedido_Id int identity (1,1) primary key ,
EstadoPedido_Descripcion nvarchar(200) ,
Estado int 
)

alter table [grupo6].[pedidos]
add EstadoPedido_Id int

ALTER TABLE [grupo6].[pedidos]
   ADD CONSTRAINT FK_estadopedido FOREIGN KEY (EstadoPedido_Id )
      REFERENCES grupo6.EstadoPedido (EstadoPedido_Id )