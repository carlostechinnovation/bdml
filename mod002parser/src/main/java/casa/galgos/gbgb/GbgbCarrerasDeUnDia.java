package casa.galgos.gbgb;

import java.io.Serializable;
import java.util.Calendar;
import java.util.List;

public class GbgbCarrerasDeUnDia implements Serializable {

	private static final long serialVersionUID = 1L;

	public Calendar fecha;
	public List<GbgbCarrera> carreras;

	public GbgbCarrerasDeUnDia(Calendar fecha, List<GbgbCarrera> carreras) {
		super();
		this.fecha = fecha;
		this.carreras = carreras;
	}

}
