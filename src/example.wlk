class Diario {
	var property personal = []
	var property ediciones = []
	var property gastosFijos
	var property auspiciantes = []
	
	method nuevoEmpleado(emp) {personal.add(emp)}			//el parametro es un elemento
	method nuevosEmpleados(emps) {personal.addAll(emps)}	//el parametro es una lista

	method nuevaEdicion(ed) {ediciones.add(ed)}
	method nuevasEdiciones(eds) {ediciones.addAll(eds)}

	method nuevoAusp(a) {auspiciantes.add(a)}
	method nuevosAusps(as) {auspiciantes.addAll(as)}
	
	//1.1)
	//La cantidad total de centímetros ocupada, de una edición del diario.
	//el criterio usado sera, "la edicion correspondiente a una determinada fecha"
	//dado que una edicion representa un dia determinado.
	method cuantosCentimetrosOcupaEsta(fecha)
	{return ediciones.filter{ed => ed.fecha() == fecha}.sum{cont => cont.cuantosCentimetros()}}
	/*filtro la/s edicion/es que responden a una fecha en cuestion
	si cada fecha representa un dia, y un dia una edicion, sumo los cm de/las ediciones
	ACOTACION PARA EL GRUPO, UN SUM{condicion} es un MAP{condicion}.SUM()*/
	//TODO mejor hacerlo en edicion
	//ya esta echa en edicion pero se llama por medio del diario para mayor comodidad.
	
	//ATENCION:
	//PARA LA CATEDRA: QUE VERSION ES MEJOR? ESTA O LA ANTERIOR?
	method cuantosCentimetrosOcupaEstaVR2(fecha)
	{return ediciones.find{ed => ed.fecha() == fecha}.cuantosCentimetros()}

	//1.2)Cuantas veces se publicó una determinada publicidad, en todas las ediciones del diario.
	method cuantasVecesSeRepiteEsta(publicidad)
	{return ediciones.sum{ed => ed.cuantasVeces(publicidad)}}
	//TODO: count
	//CONFLICTO: si uso count, se rompe el test... NO SE CALCULA BIEN.
	
	//1.3)Si durante todas las ediciones hubo algún contenido político, ya sea una nota publicada en la sección
	//"política" o una publicidad oficial (donde el auspiciante es el Estado).
	method enTodasHubocontenidoPolitico()
	{return ediciones.all{ed => ed.contenidoPolitico()}}
	//ACOTACION PARA EL GRUPO, para "todas las ediciones" usamos all
	//						   para "hubo algun cont pol" usamos any en la "class Edicion"

	//2.1)
	//metodo para vender, una determinada cantidad de ejemplares impresos
	//de una de edicion de determinada fecha
	method venderEjemplares(fecha, cantidad)
	{ediciones.filter{ed => ed.fecha() == fecha}.forEach{cont => cont.vender(cantidad)}}
	//TODO hacerlo en edicion, no hace falta buscarla
	//si hace falta buscarla, sino como vendo los ejemplares de esa fecha? no tengo manera de encontrar la edicion
	//ATENCION:
	//PARA LA CATEDRA: QUE VERSION ES MEJOR? ESTA O LA ANTERIOR?
	//filter devuelve una lisa, pero find devuelve un elemento, q es mas coherente usar¿?
	//tengo la impresion de q se aplican bien las dos...OPINIONES¿?
	method venderEjemplaresVR2(fecha, cantidad)
	{ediciones.find{ed => ed.fecha() == fecha}.vender(cantidad)}

	method cuantosEjemplaresSinVender(fecha) = ediciones.find{ed => ed.fecha() == fecha}.ejNOVendidos()

	//3.1)
	method cuantoPagarAlPersonal() = personal.sum{emp => emp.sueldo()}
	
	//filtrar todas las ediciones de un determinado mes, de un determinado año... el dia es redundante.
	method listaDeEdiciones(date) = ediciones.filter{ed => ed.fecha().month() == date.month() && ed.fecha().year() == date.year()}
	
	//metodo "ganancias" en la "class Edicion"
	//calculo la sumatoria de las ganancias
	method ganancias(date) = self.listaDeEdiciones(date).sum{ed => ed.ganancias()}

	method gananciaMensual(date) = self.ganancias(date) - gastosFijos - self.cuantoPagarAlPersonal()

	//3.2)
	//3.2)
	method promedio() {return personal.sum{p=>p.sueldo()}/personal.size()}
	method quienesCobranMasQueElPromedio()
	{return personal.filter{p=>p.sueldo() > self.promedio()}}
	//TODO ojo que tambien cobran por nota publicada
	//en ninguna consigna se establece una formula para este aspecto.
	//como lo considero? ej: X$ * cantDeNotas
	
	//3.3)Obtener el principal auspiciante del diario, que es aquel que más dinero aporta
	
	//SEA P SUB i LA PUBLICIDAD NUMERO "i"
	//POR MEDIO DE MAP Y FILTER OBTENGO "[[P1,P2,P3,P4,P5,P6],[...],[...]]"
	//ES UNA LISTA DE LISTAS DE PUBLICIDADES...
	
	//FINALMENTE, CON FLATTEN, UNIFICO TODO: [P1,P2,P3,P4,P5,P6,P7,P8,P9,..........,Pn]
	method todasLasPublicidades() = ediciones.map{ed => ed.contenidos().filter{cont => cont.esPublicidad()}}.flatten()
	
	//USANDO LA LISTA ANTERIOR, VOY A MAPEAR UN FILTRADO DE CADA PUBLICIDAD QUE CORRESPONDE A CADA
	//AUSPICIANTE, Y DE LA LISTA RESULTANTE DEL FILTRADO HAGO UNA SUMATORIA DE TODOS LOS COSTOS UNITARIOS.
	//PARA CADA AUSPICIANTE CALCULAMOS UN COSTO, SERA UNA LISTA DE COSTOS EL RESULTADO FINAL
	method cuantoCostoParaCadaAuspiciante()
	 = auspiciantes.map{a => self.todasLasPublicidades().filter{p => p.auspiciante() == a}.sum{p => p.auspiciante().costos(p)}}

	method elCostoMayor() = self.cuantoCostoParaCadaAuspiciante().max()

	method quienEsElMejorAuspiciante() = auspiciantes.find{ausp => self.todasLasPublicidades().filter{p => p.auspiciante() == ausp}.sum{p => p.auspiciante().costos(p)} >= self.elCostoMayor()}

	//4)Los auspiciantes que nunca publicaron ninguna publicidad
	method quienesNuncaPublicaronNADA() = auspiciantes.filter{ausp => self.todasLasPublicidades().filter{p => p.auspiciante() == ausp}.sum{p => p.auspiciante().costos(p)} <= 0}
}

class Edicion {
	var property contenidos = []
	var property fecha

	var property paginas = 0
	var property costo = 0

	var property ejImpresos = 0
	var property ejVendidos = 0
	var property ejNOVendidos = 0

	method nuevoContenido(cont)
	{contenidos.add(cont)}
	method nuevosContenidos(conts)
	{contenidos.addAll(conts)}

	//1.1)
	method cuantosCentimetros()
	{return contenidos.sum{cont => cont.centimetros()}}

	//1.2)
	method cuantasVeces(publicidad)
	{return contenidos.count{cont => cont == publicidad}}

	//1.3)
	method contenidoPolitico()
	{return contenidos.any{cont => cont.esPolitica()}}

	//2.1)
	//Registrar la cantidad de ejemplares NO VENDIDOS de un determinado día(REGISTRAR)
	//Se debe validar que no sea una cantidad mayor a la tirada correspondiente(USAR UN "if")
	//Si de un día no se registran ejemplares no vendidos, se asume que se vendió
	//la totalidad de los diarios impresos(no vendidos = 0 por defecto)
	method vender(cantidad)
	{	if ((ejVendidos+cantidad) <= ejImpresos)
			ejVendidos = ejVendidos+cantidad
		else ejVendidos = ejImpresos
		ejNOVendidos = ejImpresos-ejVendidos
	}
	method ventas() = ejVendidos*costo

	method ingresosPorVentas() = self.ventas()*0.5

	//debo filtrar todas las publicidades de la lista "contenidos".
	method publicidades() = contenidos.filter{cont => cont.esPublicidad()}
	//a la lista filtrada, debo calcular los costos de los auspiciantes.
	//cada publicidad sumara de a 1 su costo... no se pudo implementar una formula mas robusta.
	method ingresosPorPublicidades() = self.publicidades().sum{p => p.auspiciante().costos(p)}

	method ingresos() = self.ingresosPorVentas() + self.ingresosPorPublicidades()

	method costoImpresion() = paginas*0.25

	method ganancias() = self.ingresos() - self.costoImpresion()
}
class Nota 
{	var property periodista
	var property seccion
	var property centimetros
	method esPublicidad() = false
	method esPolitica() {return seccion == "politica"}
}
class Publicidad
{	var property auspiciante
	var property centimetros
	method esPublicidad() = true
	method esPolitica() {return auspiciante == estado}
}
class Auspiciante
{	var property costoXcm
	var property costoXcant
	var property inflacion = 10
	
	method costoXcms(p)	{return p.centimetros()*costoXcm}
	method costoXcants(){return costoXcant}
	method costos(p)		{return inflacion*(self.costoXcants() + self.costoXcms(p))}
}
class Trabajador
{	var property sueldo
	var property nombre
}
object estado inherits Auspiciante(costoXcm=10, costoXcant=20)
{
}