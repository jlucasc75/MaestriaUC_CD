/*****************************************************************************************************************
Preguntas a evaluar  
1. ¿Cúal es el porcentaje de variacion de ventas mensual del último año cerrado?
2. ¿Cuáles son los 5 productos mas vendidos mensualmente del último año cerrado?
3. ¿Cuales son los 10 clientes top en ventas mensual del último año cerrado ?
4. ¿Cuál es la participacion porcentual de pedidos segun departamentos/provincia/distrito de los últimos 6 meses?
5. ¿Cuál es el nro de pedidos no entregados/cancelados en el ultimo trimestre del año cerrado?
6. ¿Cuál es la participacion porcentual de medios de pago en la venta mensual de los  últimos 6 meses?
7. ¿Qué porcentaje de la facturacion total  se descontó en el último timestre?  
8. ¿Cuál es el tiempo promedio en dias de entrega de pedidos del último timestre?
9. ¿Cuál es el importe  de impuestos mensuales recaudados el último año cerrado?
10. ¿Cuál es la participacion porcentual de pedidos segun los servicios courier en los últimos 6 meses?
**********************************************************************************************************************/

----1. ¿Cúal es el porcentaje de variacion de ventas mensual del último año cerrado?

declare @anho int 
set @anho =2023;   --ingresar año 

WITH TotalPedidosMes AS (
    SELECT
        YEAR(p.fechapedido) AS anho,
        MONTH(p.fechapedido) AS mes,
        count(p.pedidoid) as Numeropedidos,
		sum (p.montototal) as SumMontoPedidos
    FROM
        grupo6.Pedidos p
    WHERE
        datepart(year,p.fechapedido)=@anho  --filtro de año 
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
    OVER (ORDER BY mes ),0) AS diferencia_SumMontoPedidos ,
	FORMAT(convert(decimal (15,2),isnull(SumMontoPedidos - LAG(SumMontoPedidos)
    OVER (ORDER BY mes ),0) /SumMontoPedidos) ,'0.00%')as PorcentajeVariacion
from TotalPedidosMes



-----2. ¿Cuáles son los 5 productos mas vendidos mensualmente del último año cerrado?

declare @anho int, @mes int  
set @anho =2023;  --ingresar año 
set @mes =1;      -- ingresar mes  

WITH ProductosTopMes AS (
  select 
      datepart(year,p.fechapedido) as año, 
      datepart(month,p.fechapedido) as mes, 
      po.NombreProducto+'-'+po.marca+'-'+po.modelo as producto,
      SUM(d.cantidad) as NroproductosvendidoMes
  from grupo6.Pedidos p 
	inner join grupo6.DetallesPedido d
		on p.PedidoID = d.PedidoID
	inner join grupo6.Productos po
		on d.ProductoID = po.ProductoID
  WHERE  
     datepart(year,p.fechapedido)=@anho  --filtro de año 
	 and datepart(month,p.fechapedido) =@mes --filtro mes 
	 and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
  GROUP BY 
    datepart(year,p.fechapedido) 
   ,datepart(month,p.fechapedido) 
   ,po.NombreProducto+'-'+po.marca+'-'+po.modelo
)

select  top 5  * 
from ProductosTopMes
order by NroproductosvendidoMes desc



-----3. ¿Cuales son los 10 clientes top en montos de ventas mensual del último año cerrado ?

declare @anho int
set @anho =2023;  --ingresar año 

WITH ClientesTop AS (
  select 
     datepart(year,p.fechapedido) as año, 
     cl.ClienteID,
     SUM(p.MontoTotal) as MontoCliente
  from grupo6.Pedidos p 
	inner join grupo6.Clientes cl
		on p.ClienteID = cl.ClienteID
  where datepart(year,p.fechapedido)=@anho  --filtro de año 
	 and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
  group by 
    datepart(year,p.fechapedido) , 
    cl.ClienteID
)

select  top 10  
  c.año, 
  l.nroidentidad,
  l.NombreCliente,
  c.MontoCliente as ventaacumuladacliente
from ClientesTop c
	inner join grupo6.Clientes l
		on c.ClienteID = l.ClienteID
order by MontoCliente desc



----4. ¿Cuál es la participacion porcentual de monto de pedidos segun departamentos/provincia/distrito de los últimos 6 meses?

set dateformat ymd 
declare @fechaPasada date = DATEADD(MONTH,-6,GETDATE()); ---ultimos 6 meses
declare @VentaTotal float ;

select @VentaTotal = sum (p.montototal) 
from grupo6.Pedidos p
 where p.fechapedido>= @fechaPasada --filtro de fecha 6 meses ant 
		and p.EstadoPedido_Id not in (4,5)  -- pedidos confirmados
;

WITH  PedidosGeografia AS (
  select 
    datepart(year,p.fechapedido) as año, 
    de.NombreDepartamento,
    po.NombreProvincia,
    di.NombreDistrito,
    count(p.pedidoid) as Numeropedidos,
    sum (p.montototal) as SumMontoPedidos
  from grupo6.Pedidos p 
	inner join grupo6.direccioncliente dcc 
		on p.iddireccioncliente = dcc.iddireccioncliente
	inner join grupo6.DireccionCodificada dc
		on dcc.direccioncodificadaid = dc.direccioncodificada_id
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
    ,de.NombreDepartamento
    ,po.NombreProvincia
    ,di.NombreDistrito
)

select año, 
NombreDepartamento,
NombreProvincia,
NombreDistrito,
Numeropedidos,
SumMontoPedidos,
format (convert(decimal (15,2),SumMontoPedidos/@VentaTotal),'0.00%')
from PedidosGeografia
group by 
año, 
NombreDepartamento,
NombreProvincia,
NombreDistrito,
Numeropedidos,
SumMontoPedidos
order by 1

--select @VentaTotal

-----5. ¿Cuál es el nro de pedidos no entregados/cancelados en el ultimo trimestre del año cerrado?

set dateformat ymd 

declare @anho int  
declare @trim int 
declare @venta float 

set @anho = 2023;
set @trim = 4;

select @venta =  sum (p.montototal)
from grupo6.Pedidos p
where  
DATEPART(year, p.fechapedido) =@anho  --año
and DATEPART(QUARTER, p.fechapedido) = @trim  --trimestre 
and p.EstadoPedido_Id  not in (4,5) ; -- pedidos cancelados

WITH  PedidosCancelados AS (
  select 
    datepart(year,p.fechapedido) as año, 
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
  where    DATEPART(year, p.fechapedido) =@anho  --año
        and DATEPART(QUARTER, p.fechapedido) = @trim  --trimestre 
		and p.EstadoPedido_Id  in (4,5)  -- pedidos cancelados
  group by 
    datepart(year,p.fechapedido) 
    ,datepart(month,p.fechapedido) 
    ,de.NombreDepartamento
    ,po.NombreProvincia
    ,di.NombreDistrito
)

select *,
format (convert(decimal (15,2),SumMontoPedidosnocompletados/@Venta),'0.00%') as PorcentajeSobreVentaTotal
from PedidosCancelados
order by año,mes


----6. ¿Cuál es la participacion porcentual de medios de pago en el monto de venta mensual de los  últimos 6 meses?

set dateformat ymd 
declare @fechaPasada date = DATEADD(MONTH,-6,GETDATE()); ---ultimos 6 meses
declare @ventaTotal float 

select @ventaTotal =  sum (p.montototal)
from grupo6.Pedidos p
 where 
     p.fechapedido>= @fechaPasada --filtro de fecha 6 meses ant 
	 and p.EstadoPedido_Id not in (4,5) ; -- pedidos confirmados

WITH  PedidosMediosPago AS (
   select 
     datepart(year,p.fechapedido) as año, 
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
    ,m.MedioPago
)

select * ,
format (convert(decimal (15,2),SumMontoPedidos/@VentaTotal),'0.00%') as porcentajeparticipacion
from PedidosMediosPago
order by 1



-----7. ¿Qué porcentaje de la facturacion total  se descontó en el último timestre?  
set dateformat ymd 

declare @anho int  
declare @trim int 
declare @ventaTotal float 

set @anho = 2023;
set @trim = 4;

select @ventaTotal =  sum (p.montototal)
from grupo6.Pedidos p
  where 
        DATEPART(year,p.FechaPedido) = @anho 
        and DATEPART(QUARTER, p.fechapedido) = @trim
		and p.EstadoPedido_Id not in (4,5);  -- pedidos confirmados


WITH  MontosDescontados AS (
select 
   datepart(year,p.fechapedido) as año, 
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
	  ,DATEPART(QUARTER, p.fechapedido)
)

select * ,
format (convert(decimal (15,2),MontoDescontado/@VentaTotal),'0.00%') as porcentajedescuento
from MontosDescontados
order by 1



----8. ¿Cuál es el tiempo promedio en horas de entrega de pedidos del último timestre?


set dateformat ymd 

declare @anho int  
declare @trim int 

set @anho = 2023;
set @trim = 4;

WITH  DiasentregaPedido AS (
  select 
    datepart(year,p.fechapedido) as año, 
    datepart(month,p.fechapedido) as mes, 
	count(p.PedidoID) as nropedido,
    convert (decimal (15,2), (AVG (DATEDIFF (Hour,p.FechaPedido,p.FechaEntrega)))) As DiasEntregaPromedio
  from grupo6.Pedidos p 
  where    DATEPART(year, p.fechapedido) = @anho  --año
        and DATEPART(QUARTER, p.fechapedido) = @trim  --trimestre 
		and p.EstadoPedido_Id not  in (4,5)  -- pedidos confirmados
 group by 
    datepart(year,p.fechapedido), 
    datepart(month,p.fechapedido) 
    
)

select * from  DiasentregaPedido
order by 1


----9. ¿Cuál es el importe  de impuestos mensuales recaudados el último año cerrado?

set dateformat ymd 

declare @anho int  

set @anho = 2023;

WITH  MontosImpuestos AS (
select 
   datepart(year,p.fechapedido) as año, 
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
order by año,mes



----10. ¿Cuál es la participacion porcentual de pedidos segun los servicios courier en los últimos 6 meses?

set dateformat ymd 
declare @fechaPasada date = DATEADD(MONTH,-6,GETDATE()); ---ultimos 6 meses

declare @ventaTotal float 

select @ventaTotal =  sum (p.montototal)
from grupo6.Pedidos p
 where 
     p.fechapedido>= @fechaPasada --filtro de fecha 6 meses ant 
	 and p.EstadoPedido_Id not in (4,5) ; -- pedidos confirmados


WITH  PedidosCourier AS (
   select 
     datepart(year,p.fechapedido) as año, 
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
    ,s.NombreCourier
)

select * ,
format (convert(decimal (15,2),SumMontoPedidos/@VentaTotal),'0.00%') as porcentajeparticipacion
from PedidosCourier
order by 1

