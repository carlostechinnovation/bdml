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
		return anio != null && mes != null && dia != null && real != null;
	}

	/**
	 * @param estadio
	 * @return
	 */
	public String generarInsertorUpdate(String estadio) {

		String texto_2 = ((texto != null && !texto.isEmpty()) ? ("'" + texto + "'") : null);

		String out = "INSERT INTO datos_desa.tb_galgos_weamd (";
		out += "estadio,anio,mes,dia, pasada,tempMin,tempMax,histAvgMin,histAvgMax,texto,rain,wind,cloud,sun,snow";
		out += ") VALUES (";

		out += ((estadio != null && !estadio.isEmpty()) ? ("'" + estadio + "'") : null) + ",";
		out += anio + ",";
		out += mes + ",";
		out += dia + ",";

		out += real + ",";// pasada
		out += tempMin + ",";
		out += tempMax + ",";
		out += historicAvgMin + ",";
		out += historicAvgMax + ",";
		out += texto_2 + ",";
		out += rain + ",";
		out += wind + ",";
		out += cloud + ",";
		out += sun + ",";
		out += snow;

		out += ")";
		out += " ON DUPLICATE KEY UPDATE ";

		out += " pasada=( CASE WHEN (" + real + " IS NOT NULL AND " + real + " <> '') THEN " + real
				+ " ELSE pasada END ),";

		out += " tempMin=( CASE WHEN (" + tempMin + " IS NOT NULL AND " + tempMin + " <> '') THEN " + tempMin
				+ " ELSE tempMin END ),";
		out += " tempMax=( CASE WHEN (" + tempMax + " IS NOT NULL AND " + tempMax + " <> '') THEN " + tempMax
				+ " ELSE tempMax END ),";

		out += " texto=( CASE WHEN (" + texto_2 + " IS NOT NULL AND " + texto_2 + " <> '') THEN " + texto_2
				+ " ELSE texto END ),";
		out += " rain=( CASE WHEN (" + rain + " IS NOT NULL AND " + rain + " <> '') THEN " + rain + " ELSE rain END ),";
		out += " wind=( CASE WHEN (" + wind + " IS NOT NULL AND " + wind + " <> '') THEN " + wind + " ELSE wind END ),";
		out += " cloud=( CASE WHEN (" + cloud + " IS NOT NULL AND " + cloud + " <> '') THEN " + cloud
				+ " ELSE cloud END ),";
		out += " sun=( CASE WHEN (" + sun + " IS NOT NULL AND " + sun + " <> '') THEN " + sun + " ELSE sun END ),";
		out += " snow=( CASE WHEN (" + snow + " IS NOT NULL AND " + snow + " <> '') THEN " + snow + " ELSE snow END )";

		out += ";";

		return out;
	}

	@Override
	public String toString() {
		return "AccuweatherDiaParseado [anio=" + anio + ", mes=" + mes + ", dia=" + dia + ", real=" + real
				+ ", tempMin=" + tempMin + ", tempMax=" + tempMax + ", historicAvgMin=" + historicAvgMin
				+ ", historicAvgMax=" + historicAvgMax + ", texto=" + texto + ", rain=" + rain + ", wind=" + wind
				+ ", cloud=" + cloud + ", sun=" + sun + ", snow=" + snow + "]";
	}

}
