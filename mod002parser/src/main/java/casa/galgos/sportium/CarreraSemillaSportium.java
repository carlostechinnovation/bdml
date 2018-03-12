package casa.galgos.sportium;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import utilidades.Constantes;

public class CarreraSemillaSportium implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public String urlDetalle = "\\N";
	public String estadio = "\\N";
	public Long dia = null;// yyyyMMddhhmm
	public Integer hora = null;// hhmm
	public List<SportiumGalgoFuturoEnCarreraAux> trapGalgonombreSp = new ArrayList<SportiumGalgoFuturoEnCarreraAux>();

	public CarreraSemillaSportium(String urlDetalle, String estadio, Long dia, Integer hora,
			List<SportiumGalgoFuturoEnCarreraAux> trapGalgonombreSp) {
		super();
		this.urlDetalle = urlDetalle;
		this.estadio = estadio;
		this.dia = dia;
		this.hora = hora;
		this.trapGalgonombreSp = trapGalgonombreSp;
	}

	@Override
	public String toString() {
		String out = "";

		out += dia;
		out += Constantes.SEPARADOR_CAMPO;
		out += hora;
		out += Constantes.SEPARADOR_CAMPO;
		out += estadio;

		if (trapGalgonombreSp != null && !trapGalgonombreSp.isEmpty()) {

			out += trapGalgonombreSp.size();

			for (SportiumGalgoFuturoEnCarreraAux item : trapGalgonombreSp) {
				out += Constantes.SEPARADOR_CAMPO;
				out += item.galgoNombre;
				out += Constantes.SEPARADOR_CAMPO;
				out += item.trap;
				out += Constantes.SEPARADOR_CAMPO;
				out += item.sp;
			}
		}

		out += Constantes.SEPARADOR_FILA;

		return out;
	}

}
