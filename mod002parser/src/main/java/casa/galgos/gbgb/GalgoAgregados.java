package casa.galgos.gbgb;

import java.io.Serializable;

import utilidades.Constantes;

/**
 * Clase con los ESTADISTICOS AGREGADOS de cada galgo.
 *
 */
public class GalgoAgregados implements Serializable, GalgosGuardable {

	private static final long serialVersionUID = 1L;

	public String galgo_nombre = "\\N";

	public Float velRealCortasMediana;
	public Float velRealCortasMax;
	public Float velGoingCortasMediana;
	public Float velGoingCortasMax;

	public Float velRealLongMediasMediana;
	public Float velRealLongMediasMax;
	public Float velGoingLongMediasMediana;
	public Float velGoingLongMediasMax;

	public Float velRealLargasMediana;
	public Float velRealLargasMax;
	public Float velGoingLargasMediana;
	public Float velGoingLargasMax;

	public GalgoAgregados(String galgo_nombre, Float velRealCortasMediana, Float velRealCortasMax,
			Float velGoingCortasMediana, Float velGoingCortasMax, Float velRealLongMediasMediana,
			Float velRealLongMediasMax, Float velGoingLongMediasMediana, Float velGoingLongMediasMax,
			Float velRealLargasMediana, Float velRealLargasMax, Float velGoingLargasMediana, Float velGoingLargasMax) {
		super();
		this.galgo_nombre = galgo_nombre;
		this.velRealCortasMediana = velRealCortasMediana;
		this.velRealCortasMax = velRealCortasMax;
		this.velGoingCortasMediana = velGoingCortasMediana;
		this.velGoingCortasMax = velGoingCortasMax;
		this.velRealLongMediasMediana = velRealLongMediasMediana;
		this.velRealLongMediasMax = velRealLongMediasMax;
		this.velGoingLongMediasMediana = velGoingLongMediasMediana;
		this.velGoingLongMediasMax = velGoingLongMediasMax;
		this.velRealLargasMediana = velRealLargasMediana;
		this.velRealLargasMax = velRealLargasMax;
		this.velGoingLargasMediana = velGoingLargasMediana;
		this.velGoingLargasMax = velGoingLargasMax;
	}

	@Override
	public String generarSqlCreateTable(String sufijo) {

		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_agregados" + sufijo + " (";
		out += "galgo_nombre varchar(30) NOT NULL, ";

		out += "vel_real_cortas_mediana decimal(6,4),";
		out += "vel_real_cortas_max decimal(6,4),";
		out += "vel_going_cortas_mediana decimal(6,4),";
		out += "vel_going_cortas_max decimal(6,4),";

		out += "vel_real_longmedias_mediana decimal(6,4),";
		out += "vel_real_longmedias_max decimal(6,4),";
		out += "vel_going_longmedias_mediana decimal(6,4),";
		out += "vel_going_longmedias_max decimal(6,4),";

		out += "vel_real_largas_mediana decimal(6,4),";
		out += "vel_real_largas_max decimal(6,4),";
		out += "vel_going_largas_mediana decimal(6,4),";
		out += "vel_going_largas_max decimal(6,4)";

		out += ");";
		return out;
	}

	@Override
	public String generarDatosParaExportarSql() {
		String SEP = Constantes.SEPARADOR_CAMPO;

		String out = "";

		out += (galgo_nombre != null && !"".equals(galgo_nombre)) ? galgo_nombre : "\\N";

		out += SEP;
		out += velRealCortasMediana != null ? Constantes.round2(velRealCortasMediana, 4) : "\\N";
		out += SEP;
		out += velRealCortasMax != null ? Constantes.round2(velRealCortasMax, 4) : "\\N";
		out += SEP;
		out += velGoingCortasMediana != null ? Constantes.round2(velGoingCortasMediana, 4) : "\\N";
		out += SEP;
		out += velGoingCortasMax != null ? Constantes.round2(velGoingCortasMax, 4) : "\\N";

		out += SEP;
		out += velRealLongMediasMediana != null ? Constantes.round2(velRealLongMediasMediana, 4) : "\\N";
		out += SEP;
		out += velRealLongMediasMax != null ? Constantes.round2(velRealLongMediasMax, 4) : "\\N";
		out += SEP;
		out += velGoingLongMediasMediana != null ? Constantes.round2(velGoingLongMediasMediana, 4) : "\\N";
		out += SEP;
		out += velGoingLongMediasMax != null ? Constantes.round2(velGoingLongMediasMax, 4) : "\\N";

		out += SEP;
		out += velRealLargasMediana != null ? Constantes.round2(velRealLargasMediana, 4) : "\\N";
		out += SEP;
		out += velRealLargasMax != null ? Constantes.round2(velRealLargasMax, 4) : "\\N";
		out += SEP;
		out += velGoingLargasMediana != null ? Constantes.round2(velGoingLargasMediana, 4) : "\\N";
		out += SEP;
		out += velGoingLargasMax != null ? Constantes.round2(velGoingLargasMax, 4) : "\\N";

		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	@Override
	public String generarPath(String pathDirBase) {
		return pathDirBase + "tb_galgos_agregados_file";
	}

}
