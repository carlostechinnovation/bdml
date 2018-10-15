package casa.galgos.weather;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Modelo con el contenido de haber parseado una web bruta de ACCUWEATHER, que
 * es de un MES.
 *
 */
public class AccuweatherParseado implements Serializable {

	private static final long serialVersionUID = 1940564997513490524L;

	public Integer anio;
	public Integer mes;
	public String estadio;
	public List<AccuweatherDiaParseado> diasParseados;

	public AccuweatherParseado() {
		super();
		this.diasParseados = new ArrayList<AccuweatherDiaParseado>();
	}

	@Override
	public String toString() {
		return "AccuweatherParseado [diasParseados=" + diasParseados.size() + "]";
	}

	/**
	 * @return True si todos los dias han sido parseados y todos son del PASADO.
	 */
	public boolean sonTodosCompletosYPasados() {
		boolean out = true;
		if (diasParseados.size() >= 28) {
			for (AccuweatherDiaParseado adp : diasParseados) {
				if (adp.minimoRelleno() && adp.real == false) {
					out = false;
				}
			}
		}

		return out;
	}

}
