package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class GbgbGalgoHistorico implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String galgo_nombre;
	public List<GbgbGalgoHistoricoCarrera> carrerasHistorico;

	public GbgbGalgoHistorico(String galgo_nombre) {
		super();
		this.galgo_nombre = galgo_nombre;
		carrerasHistorico = new ArrayList<GbgbGalgoHistoricoCarrera>();
	}

}
