package casa.galgos.weather;

import java.io.Serializable;

/**
 * Modelo con el contenido de haber parseado una web bruta de ACCUWEATHER.
 *
 */
public class AccuweatherDiaParseado implements Serializable {

	private static final long serialVersionUID = 1940564997513490524L;

	public Integer anio, mes, dia;
	public Boolean real; // TRUE (si es temperatura real, es decir, pasada) o FALSE (si es predicha, del
							// futuro)
	public Integer tempMin, tempMax;
	public Integer historicAvgMin, historicAvgMax;
	public String texto;
	public Boolean rain; // or showers
	public Boolean wind;
	public Boolean cloud;
	public Boolean sun;
	public Boolean snow;

	/**
	 * @return
	 */
	public boolean minimoRelleno() {
		return anio != null && mes != null && dia != null && real != null && historicAvgMin != null
				&& historicAvgMax != null;
	}

	public String generarInsertorUpdate() {
		// TODO Pendiente
		// INSERT INTO devices(id,name) VALUES (4,'Printer') ON DUPLICATE KEY UPDATE
		// name = 'Central Printer';
		return "PENDIENTE";
	}

	@Override
	public String toString() {
		return "AccuweatherDiaParseado [anio=" + anio + ", mes=" + mes + ", dia=" + dia + ", real=" + real
				+ ", tempMin=" + tempMin + ", tempMax=" + tempMax + ", historicAvgMin=" + historicAvgMin
				+ ", historicAvgMax=" + historicAvgMax + ", texto=" + texto + ", rain=" + rain + ", wind=" + wind
				+ ", cloud=" + cloud + ", sun=" + sun + ", snow=" + snow + "]";
	}

}
