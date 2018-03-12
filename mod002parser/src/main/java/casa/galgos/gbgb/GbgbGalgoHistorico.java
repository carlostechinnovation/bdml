package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import utilidades.Constantes;

public class GbgbGalgoHistorico implements Serializable, GalgosGuardable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String galgo_nombre = "\\N";
	public String entrenador = "\\N";
	public String padre_madre_nacimiento = "\\N";

	public List<GbgbGalgoHistoricoCarrera> carrerasHistorico;

	// para debug
	public int error_causa = 0;// -1 (Galgo no encontrado), -2 (galgo encontrado, pero no conocemos carreras
								// pasadas)

	public GbgbGalgoHistorico(boolean todoNulos) {
		super();
	}

	/**
	 * @param error_causa
	 *            -1 (Galgo no encontrado), -2 (galgo encontrado, pero no conocemos
	 *            carreras pasadas)
	 */
	public GbgbGalgoHistorico(int error_causa) {
		super();
		this.error_causa = error_causa;
	}

	public GbgbGalgoHistorico(String galgo_nombre, String entrenador, String padre_madre_nacimiento) {
		super();
		this.galgo_nombre = galgo_nombre;
		this.entrenador = entrenador;
		this.padre_madre_nacimiento = padre_madre_nacimiento;
		carrerasHistorico = new ArrayList<GbgbGalgoHistoricoCarrera>();
	}

	@Override
	public String generarSqlCreateTable(String sufijo) {
		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_historico" + sufijo + " ("
				+ "galgo_nombre varchar(30) NOT NULL, entrenador varchar(30), "
				+ GbgbGalgoHistoricoCarrera.generarCamposSqlCreateTableDeDetalle() + ");";
	}

	@Override
	public String generarDatosParaExportarSql() {

		String SEP = Constantes.SEPARADOR_CAMPO;

		String out = "";

		for (GbgbGalgoHistoricoCarrera fila : carrerasHistorico) {

			String entrenadorLimpio = Constantes.limpiarEntrenador(entrenador);

			out += (galgo_nombre != null && !"".equals(galgo_nombre)) ? galgo_nombre : "\\N";
			out += SEP;
			out += (entrenadorLimpio != null) ? entrenadorLimpio : "\\N";
			out += SEP;
			out += fila.generarDatosParaExportarSql() + Constantes.SEPARADOR_FILA;
		}

		return out;
	}

	@Override
	public String generarPath(String pathDirBase) {
		return pathDirBase + "tb_galgos_historico_file";
	}

	@Override
	public String toString() {
		return "GbgbGalgoHistorico [...]";
	}

}
