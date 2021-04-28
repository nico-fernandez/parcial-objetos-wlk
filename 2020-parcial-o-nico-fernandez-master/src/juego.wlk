class Estampilla {

	var property pais
	var property anioDeEmision
	var property valorFacial = 0
	var property motivo

	method esAntigua() {
		return self.antiguedad() >= 100
	}

	method esModerna() {
		return not self.esAntigua()
	}

	method esFallada() {
		return not pais.anioValido(anioDeEmision)
	}

	method cotizacionInicial() {
		return self.valorFacial() * pais.coeficiente()
	}

	method antiguedad() {
		return tiempo.anioActual() - anioDeEmision
	}

	method adicionalPorAntiguedad() {
		return 5 * (self.antiguedad() - 100).max(0)
	}

	method cotizacion() {
		if (self.esFallada()) {
			return 1000000
		} else {
			return self.cotizacionInicial() + self.adicionalPorAntiguedad().min(150)
		}
	}

	// Para la variante de considerar las estampillas que forman parte de una Hojita Block   
	// Cualquier estampilla se corresponde consigo misma. 
	method corresponde(estampilla) {
		return estampilla == self
	}

	// Para la variante de contar la cantidad de estampillas que forman parte de una Hojita Block
	// Para cualquier estampilla, la cantidad es 1   
	method cantidad() = 1

}

class Conmemorativa inherits Estampilla {

	override method cotizacionInicial() {
		return super() * self.aumentoConmemorativaYZonal()
	}

	method aumentoConmemorativaYZonal() {
		if (motivo.contains("Zárate") or motivo.contains("Campana")) {
			return 3
		} else {
			return 2
		}
	}

}

class HojitaBlock inherits Conmemorativa {

	const estampillas = []

	override method valorFacial() {
		return estampillas.sum({ unaEstampilla => unaEstampilla.valorFacial() })
	}

	override method esFallada() {
		return estampillas.any({ unaEstampilla => unaEstampilla.anioDeEmision() != anioDeEmision or unaEstampilla.pais() != pais })
	}

	// Para la variante de considerar las estampillas que forman parte de una Hojita Block   
	override method corresponde(estampilla) {
		return estampillas.contains(estampilla) or super(estampilla)
	}

	// Para la variante de contar la cantidad de estampillas que forman parte de una Hojita Block
	override method cantidad() {
		return estampillas.size()
	}

}

object asociacion {

	var property miembros = []

	method esComun(estampilla) {
		return miembros.count({ unMiembro => unMiembro.tiene(estampilla) }) > 10
	}

	method coleccionMayorCotizacion() {
		return miembros.max({ unMiembro => unMiembro.totalCotizacion() })
	}

}

class Miembro {

	var property estampillas = []
	const paisesDeInteres = []

	method tiene(estampilla) {
		return estampillas.contains(estampilla)
	}

	// Considerando la hojita Block
	method tieneVariante(estampilla) {
		return estampillas.any({ unaEstampilla => unaEstampilla.corresponde(estampilla) })
	}

	method leInteresa(estampilla) {
		return not self.tiene(estampilla) and self.paisDeInteres(estampilla.pais())
	}

	method cuantasEstampillasTenesDe(pais) {
		return estampillas.count({ unaEstampilla => unaEstampilla.pais() == pais })
	}

	// Las hojitas block se cuentan como las estampillas que contiene
	method cuantasEstampillasTenesDeHojita(pais) {
		return estampillas.filter({ unaEstampilla => unaEstampilla.pais() }).sum({ unaEstampilla => unaEstampilla.cantidad() })
	}

	method totalCotizacion() {
		return estampillas.sum({ unaEstampilla => unaEstampilla.cotizacion() })
	}

	method paisDeInteres(pais) {
		return paisesDeInteres.contains(pais)
	}

}

class Pais {

	var property coeficiente
	var property comienzo = 1840 // Creacion de la primera estampilla
	var property fin = null // Esto significa que el pais todavia existe

	method anioValido(anio) {
		return self.anioComienzoValido(anio) and self.anioFinValido(anio)
	}

	method anioComienzoValido(anio) {
		return anio >= comienzo
	}

	method anioFinValido(anio) {
		if (fin == null) {
			return true
		} else {
			return anio <= fin
		}
	}

}

object tiempo {

	var property anioActual = 2020

	method pasoElTiempo(anios) {
		anioActual = anioActual + anios
	}

}

