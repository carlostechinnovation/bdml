package casa.galgos;

import java.io.Serializable;
import java.util.List;

public class ProfundidadCarreras implements Serializable {

	Integer profundidad;
	List<String> carrerasPendientes;// Cada carrera está iden: ID_carrera-ID_campeonato

	public ProfundidadCarreras(Integer profundidad, List<String> carrerasPendientes) {
		super();
		this.profundidad = profundidad;
		this.carrerasPendientes = carrerasPendientes;
	}

	public boolean anhadirCarreraPendiente(String carrera) {
		return carrerasPendientes.add(carrera);
	}

	public boolean quitarCarreraPendiente(String carrera) {
		return carrerasPendientes.remove(carrera);
	}

}
