package casa.galgos.gbgb;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class GbgbCarrerasInfoUtilHttp implements Serializable {

	private static final long serialVersionUID = 1L;

	public List<Long> listaIdsCarreras;
	public List<Long> listaIdsCampeonatos;

	public GbgbCarrerasInfoUtilHttp() {
		super();
		this.listaIdsCarreras = new ArrayList<Long>();
		this.listaIdsCampeonatos = new ArrayList<Long>();
	}

}
