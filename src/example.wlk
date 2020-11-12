class Linea{
	const property numeroTelefono = new Number()
	const property packActivos = new List()
	var property gastos = 0
	const property operacionesRealizadas = new List()
	var property hoy = new Date()
	var property tipoLinea
	var property deuda = new List()

	method realizarOperacion(consumo){
		self.agregarGastos(consumo.consumo())
		self.operacionesRealizadas().add(consumo)
	} 
	
		//punto 4
	method agregarPack(packNuevo) = packActivos.add(packNuevo)
	
	//punto 5	
	method algunoPuedeSatisfacer(consumo) = packActivos.any({unPack => unPack.satisface(consumo)})

	//punto 6
	method realizarConsumoConPack(consumo) = tipoLinea.realizarConsumo(consumo, self)
	
	method efectuarConsumo(consumo){
		const aux = packActivos.filter({unPack => unPack.satisface(consumo)}).last()
			packActivos.remove(aux)
			aux.realizarCambios(consumo)
			packActivos.add(aux)
			self.realizarOperacion(consumo)
	}
	
	//punto 7
	method limpiezaDePack() = packActivos.removeAll(packActivos.filter({unPack => unPack.limpieza(self)}))
	
		
	//punto 2
	method agregarGastos(gastoNuevo){
		gastos += gastoNuevo
	}
	
	
	//punto 2a
	method promedioConsumos(fechaInicial, fechaFinal){
		return self.promedioFiltrado(self.filtrarOperacionesRealizadas(fechaInicial, fechaFinal))
	}
	
	method promedioFiltrado(listaFiltrada) = listaFiltrada.map({unaOperacion => unaOperacion.consumo()}).sum()/listaFiltrada.size()
	
	//punto 2b
	method costoTotalMes(fechaActual) = self.filtrarOperacionesRealizadas((fechaActual.minusDays(30)), fechaActual).map({unaOperacion => unaOperacion.consumo()}).sum()
	
	
	method filtrarOperacionesRealizadas(fechaInicial, fechaFinal) = operacionesRealizadas.filter({unaOperacion => unaOperacion.fechaDeRealizacion().betwwen(fechaInicial, fechaFinal)})
}


//punto 8
object comun{
	method realizarConsumo(consumo, linea){
		if(linea.algunoPuedeSatisfacer(consumo)) linea.efectuarConsumo(consumo)
		
		else self.error("ningun pack puede realizar el consumo")
	}
}

object black{
	method realizarConsumo(consumo, linea){
		if(linea.algunoPuedeSatisfacer(consumo)){
			linea.efectuarConsumo(consumo)
		}
		else linea.deuda().add(consumo)
	}
}

object platinum{
	method realizarConsumo(consumo, linea){
		if(linea.algunoPuedeSatisfacer(consumo)) linea.efectuarConsumo(consumo)
		
		else linea.realizarOperacion(consumo)
	}
}
//punto 1
class Consumos{
	const property fechaDeRealizacion = new Date()
	var property cantidad = new Number()
	
	
	method consumo()
	
	
	
	method esWeekend() = true
	
}

class ConsumoLlamada inherits Consumos{
	const property unidad = "SG"
	
	
	override method consumo() = 1 + (cantidad - 30).max(0) * 0.05
	
	override method esWeekend() = fechaDeRealizacion.dayOfWeek() == sunday or fechaDeRealizacion.dayOfWeek() == saturday
}

class ConsumoInternet inherits Consumos{
	const property unidad = "MB"
	
	
	override method consumo() = cantidad * 0.1
	
}


class Packs{
	var property fechaVencimiento = new Date()
	
	//punto 3
	method satisface(consumo) = self.puedeSatisfacer(consumo) && fechaVencimiento > consumo.fechaDeRealizacion()

	method puedeSatisfacer(consumo)
	
	method realizarCambios(consumo)
	
	method limpieza(linea) = fechaVencimiento < linea.hoy()	

}
 
class CreditoDisponible inherits Packs{
	var property cantidadCredito = new Number()
	
	override method puedeSatisfacer(consumo) = cantidadCredito >= consumo.consumo()

	override method realizarCambios(consumo){
		cantidadCredito -= consumo.consumo()	
	}
	
	override method limpieza(linea) = super(linea) or cantidadCredito == 0
		

}

class CantidadMegasLibres inherits Packs{
	var property cantidadMegas
	const unidad = "MB"
	
	override method puedeSatisfacer(consumo) = consumo.unidad() == unidad && consumo.consumo() > cantidadMegas

	override method realizarCambios(consumo){
		cantidadMegas -= consumo.consumo() 
	}	
	
	override method limpieza(linea) = super(linea) or cantidadMegas == 0
}

class LlamadasGratis inherits Packs{
	var property cantidadLlamadasGratis
	const unidad = "SG"
	override method puedeSatisfacer(consumo) = unidad == consumo.unidad() && cantidadLlamadasGratis > 0
}

class InternetLibreEnFindes inherits Packs{
	const unidad = "MB"
	override method puedeSatisfacer(consumo) = unidad == consumo.unidad() && consumo.esWeekend()
}

//class MBLibresMasMas inherits CantidadMegasLibres{
	
	//override method puedeSatisfacer(consumo){
		
		
	//}
//}
