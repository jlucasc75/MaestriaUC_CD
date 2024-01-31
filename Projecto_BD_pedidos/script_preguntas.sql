/*****************************************************************************************************************
Preguntas a evaluar  
1. �C�al es el porcentaje de variacion de ventas mensual del �ltimo a�o cerrado?
2. �Cu�les son los 5 productos mas vendidos mensualmente del �ltimo a�o cerrado?
3. �Cuales son los 10 clientes top en ventas mensual del �ltimo a�o cerrado ?
4. �Cu�l es la participacion porcentual de pedidos segun departamentos/provincia/distrito de los �ltimos 6 meses?
5. �Cu�l es el nro de pedidos no entregados/cancelados en el ultimo trimestre del a�o cerrado?
6. �Cu�l es la participacion porcentual de medios de pago en la venta mensual de los  �ltimos 6 meses?
7. �Qu� porcentaje de la facturacion total  se descont� en el �ltimo timestre?  
8. �Cu�l es el tiempo promedio en dias de entrega de pedidos del �ltimo timestre?
9. �Cu�l es el importe  de impuestos mensuales recaudados el �ltimo a�o cerrado?
10. �Cu�l es la participacion porcentual de pedidos segun los servicios courier en los �ltimos 6 meses?
**********************************************************************************************************************/

----1. �C�al es el porcentaje de variacion de ventas mensual del �ltimo a�o cerrado?

declare @anho int 
set @anho =2023;   --ingresar a�o 

WITH TotalPedidosMes AS (
    SELECT
        YEAR(p.fechapedido) AS anho,
        MONTH(p.fechapedido) AS mes,
        count(p.pedidoid) as Numeropedidos,
		sum (p.montototal) as SumMontoPedidos
    FROM
        grupo6.Pedidos p
    WHERE
        datepart(year,p.fechapedido)=@anho  --filtro de a�o 
	    and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
  group by 
        YEAR(p.fechapedido) ,
        MONTH(p.fechapedido) 
)

select 
   anho,
   mes,
   numeropedidos ,
   isnull(numeropedidos - LAG(numeropedidos)
    OVER (ORDER BY mes ),0) AS diferencia_nropedidos ,
    SumMontoPedidos,
   isnull(SumMontoPedidos - LAG(SumMontoPedidos)
    OVER (ORDER BY mes ),0) AS diferencia_SumMontoPedidos 
from TotalPedidosMes



-----2. �Cu�les son los 5 productos mas vendidos mensualmente del �ltimo a�o cerrado?

declare @anho int, @mes int  
set @anho =2023;  --ingresar a�o 
set @mes =1;      -- ingresar mes  

WITH ProductosTopMes AS (
  select 
      datepart(year,p.fechapedido) as a�o, 
      datepart(month,p.fechapedido) as mes, 
      po.NombreProducto+'-'+po.marca+'-'+po.modelo as producto,
      SUM(d.cantidad) as Nroproductosvendido
  from grupo6.Pedidos p 
	inner join grupo6.DetallesPedido d
		on p.PedidoID = d.PedidoID
	inner join grupo6.Productos po
		on d.ProductoID = po.ProductoID
  WHERE  
     datepart(year,p.fechapedido)=@anho  --filtro de a�o 
	 and datepart(month,p.fechapedido) =@mes --filtro mes 
	 and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
  GROUP BY 
    datepart(year,p.fechapedido) 
   ,datepart(month,p.fechapedido) 
   ,po.NombreProducto+'-'+po.marca+'-'+po.modelo
)

select  top 5  * 
from ProductosTopMes
order by Nroproductosvendido desc



-----3. �Cuales son los 10 clientes top en ventas mensual del �ltimo a�o cerrado ?

declare @anho int
set @anho =2023;  --ingresar a�o 

WITH ClientesTop AS (
  select 
     datepart(year,p.fechapedido) as a�o, 
     cl.ClienteID,
     SUM(p.MontoTotal) as MontoCliente
  from grupo6.Pedidos p 
	inner join grupo6.Clientes cl
		on p.ClienteID = cl.ClienteID
  where datepart(year,p.fechapedido)=@anho  --filtro de a�o 
	 and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
  group by 
    datepart(year,p.fechapedido) , 
    cl.ClienteID
)

select  top 10  
  c.a�o, 
  l.nroidentidad,
  l.NombreCliente,
  c.MontoCliente as ventaacumuladacliente
from ClientesTop c
	inner join grupo6.Clientes l
		on c.ClienteID = l.ClienteID
order by MontoCliente desc



----4. �Cu�l es la participacion porcentual de pedidos segun departamentos/provincia/distrito de los �ltimos 6 meses?

set dateformat ymd 
declare @fechaPasada date = DATEADD(MONTH,-6,GETDATE()); ---ultimos 6 meses

WITH  PedidosGeografia AS (
  select 
    datepart(year,p.fechapedido) as a�o, 
    datepart(month,p.fechapedido) as mes, 
    de.NombreDepartamento,
    po.NombreProvincia,
    di.NombreDistrito,
    count(p.pedidoid) as Numeropedidos,
    sum (p.montototal) as SumMontoPedidos
  from grupo6.Pedidos p 
	inner join grupo6.DireccionCodificada dc
		on p.IdDireccionCliente = dc.direccioncodificada_id
	inner join grupo6.distrito di 
		on dc.distrito_id = di.Distrito_id
	inner join grupo6.provincia po
		on di.Provincia_id =po.Provincia_Id
	inner join grupo6.departamento de
		on po.Departamento_id = de.departamento_Id
   where p.fechapedido>= @fechaPasada --filtro de fecha 6 meses ant 
		and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
   group by 
     datepart(year,p.fechapedido) 
    ,datepart(month,p.fechapedido) 
    ,de.NombreDepartamento
    ,po.NombreProvincia
    ,di.NombreDistrito
)

select * from PedidosGeografia
order by a�o, mes 


-----5. �Cu�l es el nro de pedidos no entregados/cancelados en el ultimo trimestre del a�o cerrado?

set dateformat ymd 

declare @anho int  
declare @trim int 

set @anho = 2023;
set @trim = 4;

WITH  PedidosCancelados AS (
  select 
    datepart(year,p.fechapedido) as a�o, 
    datepart(month,p.fechapedido) as mes, 
    de.NombreDepartamento,
    po.NombreProvincia,
    di.NombreDistrito,
    count(p.pedidoid) as Numeropedidosnocompletados,
    sum (p.montototal) as SumMontoPedidosnocompletados
  from grupo6.Pedidos p 
	inner join grupo6.DireccionCodificada dc
		on p.IdDireccionCliente = dc.direccioncodificada_id
	inner join grupo6.distrito di 
		on dc.distrito_id = di.Distrito_id
	inner join grupo6.provincia po
		on di.Provincia_id =po.Provincia_Id
	inner join grupo6.departamento de
		on po.Departamento_id = de.departamento_Id
  where    DATEPART(year, p.fechapedido) =@anho  --a�o
        and DATEPART(QUARTER, p.fechapedido) = @trim  --trimestre 
		and p.EstadoPedido_Id  in (4,5)  -- pedidos cancelados
  group by 
    datepart(year,p.fechapedido) 
    ,datepart(month,p.fechapedido) 
    ,de.NombreDepartamento
    ,po.NombreProvincia
    ,di.NombreDistrito
)

select * from PedidosCancelados
order by a�o,mes



----6. �Cu�l es la participacion porcentual de medios de pago en la venta mensual de los  �ltimos 6 meses?

set dateformat ymd 
declare @fechaPasada date = DATEADD(MONTH,-6,GETDATE()); ---ultimos 6 meses

WITH  PedidosMediosPago AS (
   select 
     datepart(year,p.fechapedido) as a�o, 
     datepart(month,p.fechapedido) as mes, 
     m.MedioPago,
     count(p.pedidoid) as Numeropedidos,
     sum (p.montototal) as SumMontoPedidos
   from grupo6.Pedidos p 
	 inner join grupo6.MedioPago m
		on p.MedioPago_id = m.MedioPago_id
   where 
     p.fechapedido>= @fechaPasada --filtro de fecha 6 meses ant 
	 and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
   group by 
     datepart(year,p.fechapedido) 
    ,datepart(month,p.fechapedido) 
    ,m.MedioPago
)

select * 
from PedidosMediosPago
order by a�o,mes



-----7. �Qu� porcentaje de la facturacion total  se descont� en el �ltimo timestre?  
set dateformat ymd 

declare @anho int  
declare @trim int 

set @anho = 2023;
set @trim = 4;

WITH  MontosDescontados AS (
select 
   datepart(year,p.fechapedido) as a�o, 
   datepart(month,p.fechapedido) as mes, 
   DATEPART(QUARTER, p.fechapedido) as trimestre ,
   count(p.pedidoid)  as Numeropedidos,
   sum (p.montototal) as FacturacionPedidos,
   sum (case when (d.Descuento>0) then 1 else 0 end ) as  PedidosconDescuentos  ,
   sum (d.descuento)  as MontoDescontado
   from grupo6.Pedidos p 
	inner join grupo6.DetallesPedido d
		on p.PedidoID = d.PedidoID
   where 
        DATEPART(year,p.FechaPedido) = @anho 
        and DATEPART(QUARTER, p.fechapedido) = @trim
		and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
   group by 
       datepart(year,p.fechapedido) 
      ,datepart(month,p.fechapedido)
	  ,DATEPART(QUARTER, p.fechapedido)
)

select * ,
convert (decimal (15,2), (MontoDescontado/FacturacionPedidos)) *100  as PorcentajeDescuento
from MontosDescontados
order by a�o,mes


----8. �Cu�l es el tiempo promedio en dias de entrega de pedidos del �ltimo timestre?


set dateformat ymd 

declare @anho int  
declare @trim int 

set @anho = 2023;
set @trim = 4;

WITH  DiasentregaPedido AS (
  select 
    datepart(year,p.fechapedido) as a�o, 
    datepart(month,p.fechapedido) as mes, 
    de.NombreDepartamento,
    po.NombreProvincia,
    di.NombreDistrito,
	count(p.PedidoID) as nropedido,
    AVG (DATEDIFF (day,p.FechaPedido,p.FechaEntrega)) As DiasEntregaPromedio
  from grupo6.Pedidos p 
	inner join grupo6.DireccionCodificada dc
		on p.IdDireccionCliente = dc.direccioncodificada_id
	inner join grupo6.distrito di 
		on dc.distrito_id = di.Distrito_id
	inner join grupo6.provincia po
		on di.Provincia_id =po.Provincia_Id
	inner join grupo6.departamento de
		on po.Departamento_id = de.departamento_Id
  where    DATEPART(year, p.fechapedido) = @anho  --a�o
        and DATEPART(QUARTER, p.fechapedido) = @trim  --trimestre 
		and p.EstadoPedido_Id not  in (4,5)  -- pedidos confirmados
 group by 
    datepart(year,p.fechapedido), 
    datepart(month,p.fechapedido), 
    de.NombreDepartamento,
    po.NombreProvincia,
    di.NombreDistrito
)

select * from  DiasentregaPedido
order by a�o,mes


----9. �Cu�l es el importe  de impuestos mensuales recaudados el �ltimo a�o cerrado?

set dateformat ymd 

declare @anho int  

set @anho = 2023;

WITH  MontosImpuestos AS (
select 
   datepart(year,p.fechapedido) as a�o, 
   datepart(month,p.fechapedido) as mes, 
   sum (p.montototal) as FacturacionTotal,
   sum (d.Impuesto)  as MontoImpuesto
   from grupo6.Pedidos p 
	inner join grupo6.DetallesPedido d
		on p.PedidoID = d.PedidoID
   where 
        DATEPART(year,p.FechaPedido) = @anho 
		and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
   group by 
       datepart(year,p.fechapedido) 
      ,datepart(month,p.fechapedido)

)

select * 
from MontosImpuestos
order by a�o,mes



----10. �Cu�l es la participacion porcentual de pedidos segun los servicios courier en los �ltimos 6 meses?


set dateformat ymd 
declare @fechaPasada date = DATEADD(MONTH,-6,GETDATE()); ---ultimos 6 meses

WITH  PedidosCourier AS (
   select 
     datepart(year,p.fechapedido) as a�o, 
     datepart(month,p.fechapedido) as mes, 
     s.NombreCourier,
     count(p.pedidoid) as Numeropedidos,
     sum (p.montototal) as SumMontoPedidos
   from grupo6.Pedidos p 
	 inner join grupo6.serviciocourier s
		on p.serviciocourierid = s.serviciocourierID

   where 
     p.fechapedido>= @fechaPasada --filtro de fecha 6 meses ant 
	 and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
   group by 
     datepart(year,p.fechapedido) 
    ,datepart(month,p.fechapedido) 
    ,s.NombreCourier
)

select * 
from PedidosCourier
order by a�o,mes
