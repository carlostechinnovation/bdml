package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class GbgbGalgoHistorico implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String galgo_nombre;
	public String entrenador;
	public String padre_madre_nacimiento;

	public List<GbgbGalgoHistoricoCarrera> carrerasHistorico;

	public GbgbGalgoHistorico(String galgo_nombre, String entrenador, String padre_madre_nacimiento) {
		super();
		this.galgo_nombre = galgo_nombre;
		this.entrenador = entrenador;
		this.padre_madre_nacimiento = padre_madre_nacimiento;
		carrerasHistorico = new ArrayList<GbgbGalgoHistoricoCarrera>();
	}

}
