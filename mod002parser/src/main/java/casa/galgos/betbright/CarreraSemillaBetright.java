package casa.galgos.betbright;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import utilidades.Constantes;

public class CarreraSemillaBetright implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String urlDetalle;

	public Long dia;// yyyyMMddhhmm
	public Integer hora;// hhmm
	public String estadio;
	public String tipoPista;
	public Integer distancia;
	public List<CarreraGalgoSemillaBetright> listaCG = new ArrayList<CarreraGalgoSemillaBetright>();

	public CarreraSemillaBetright(String urlDetalle, Long dia, Integer hora, String estadio, String tipoPista,
			Integer distancia, List<CarreraGalgoSemillaBetright> listaCG) {
		super();
		this.urlDetalle = urlDetalle;
		this.dia = dia;
		this.hora = hora;
		this.estadio = estadio;
		this.tipoPista = tipoPista;
		this.distancia = distancia;
		this.listaCG = listaCG;
	}

	@Override
	public String toString() {
		String out = "";

		out += dia;
		out += Constantes.SEPARADOR_CAMPO;
		out += hora;
		out += Constantes.SEPARADOR_CAMPO;
		out += estadio;
		out += Constantes.SEPARADOR_CAMPO;
		out += tipoPista;
		out += Constantes.SEPARADOR_CAMPO;
		out += distancia;
		out += Constantes.SEPARADOR_CAMPO;
		out += (listaCG != null && !listaCG.isEmpty()) ? listaCG.size() : "";
		out += Constantes.SEPARADOR_FILA;

		return out;
	}

}
