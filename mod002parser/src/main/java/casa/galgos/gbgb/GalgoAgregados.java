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
	public Float velocidadRealMediaReciente;
	public Float velocidadConGoingMediaReciente;

	public GalgoAgregados(String galgo_nombre, Float velocidadRealMediaReciente, Float velocidadConGoingMediaReciente) {
		super();
		this.galgo_nombre = galgo_nombre;
		this.velocidadRealMediaReciente = velocidadRealMediaReciente;
		this.velocidadConGoingMediaReciente = velocidadConGoingMediaReciente;
	}

	@Override
	public String generarSqlCreateTable() {

		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_agregados (" + "galgo_nombre varchar(30) NOT NULL, "
				+ "velocidad_real_media_reciente decimal(6,4), velocidad_con_going_media_reciente decimal(6,4)" + ");";
	}

	@Override
	public String generarDatosParaExportarSql() {
		String SEP = Constantes.SEPARADOR_CAMPO;

		String out = "";

		out += galgo_nombre;
		out += SEP;
		out += velocidadRealMediaReciente;
		out += SEP;
		out += velocidadConGoingMediaReciente;

		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	@Override
	public String generarPath(String pathDirBase) {
		return pathDirBase + "tb_galgos_agregados_file";
	}

}
