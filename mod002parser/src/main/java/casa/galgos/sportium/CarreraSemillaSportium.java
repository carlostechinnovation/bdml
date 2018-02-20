package casa.galgos.sportium;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import utilidades.Constantes;

public class CarreraSemillaSportium implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String urlDetalle;
	public String estadio;
	public Long dia;// yyyyMMddhhmm
	public Integer hora;// hhmm
	public List<String> galgosNombres = new ArrayList<String>();// ordenados segun el trap

	public CarreraSemillaSportium(String urlDetalle, String estadio, Long dia, Integer hora, List<String> galgosNombres) {
		super();
		this.urlDetalle = urlDetalle;
		this.estadio = estadio;
		this.dia = dia;
		this.hora = hora;
		this.galgosNombres = galgosNombres;
	}

	@Override
	public String toString() {
		String out = "";

		out += dia;
		out += Constantes.SEPARADOR_CAMPO;
		out += hora;
		out += Constantes.SEPARADOR_CAMPO;
		out += estadio;

		if (galgosNombres != null && !galgosNombres.isEmpty()) {

			out += galgosNombres.size();

			for (String galgo : galgosNombres) {

				out += Constantes.SEPARADOR_CAMPO;
				out += galgo;
			}
		}

		out += Constantes.SEPARADOR_FILA;

		return out;
	}

}
