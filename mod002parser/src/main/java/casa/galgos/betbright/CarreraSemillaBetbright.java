package casa.galgos.betbright;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import utilidades.Constantes;

public class CarreraSemillaBetbright implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String urlDetalle;

	public Long dia = null;// yyyyMMddhhmm
	public Integer hora = null;// hhmm
	public String estadio = "\\N";
	public String tipoPista = "\\N";
	public Integer distancia = null;
	public List<CarreraGalgoSemillaBetbright> listaCG = new ArrayList<CarreraGalgoSemillaBetbright>();

	public CarreraSemillaBetbright(String urlDetalle, Long dia, Integer hora, String estadio, String tipoPista,
			Integer distancia, List<CarreraGalgoSemillaBetbright> listaCG) {
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
		String out = "CSBB = ";

		out += dia != null ? dia : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += hora != null ? hora : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += estadio != null && !estadio.isEmpty() ? estadio : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += tipoPista != null && !tipoPista.isEmpty() ? tipoPista : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += distancia != null ? distancia : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += (listaCG != null && !listaCG.isEmpty()) ? listaCG.size() : "\\N";
		out += Constantes.SEPARADOR_FILA;

		return out;
	}

}
