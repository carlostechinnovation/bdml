package casa.galgos.weather;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Modelo con el contenido de haber parseado una web bruta de ACCUWEATHER.
 *
 */
public class AccuweatherParseado implements Serializable {

	private static final long serialVersionUID = 1940564997513490524L;

	public List<AccuweatherDiaParseado> diasParseados;

	public AccuweatherParseado() {
		super();
		this.diasParseados = new ArrayList<AccuweatherDiaParseado>();
	}

	@Override
	public String toString() {
		return "AccuweatherParseado [diasParseados=" + diasParseados.size() + "]";
	}

}
