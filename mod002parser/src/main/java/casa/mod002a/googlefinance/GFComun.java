package casa.mod002a.googlefinance;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public abstract class GFComun extends ParserDeDia {
	
	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");

		List<String> listaOut = new ArrayList<String>();

		// JSON
		try {
			JSONObject obj = (JSONObject) (new JSONParser()).parse(in);

			Integer numeroFilas = Integer.valueOf((String) obj.get("num_company_results"));

			JSONArray resultados = (JSONArray) obj.get("searchresults");

			int numeroResultados = resultados.size();

			Iterator it = resultados.iterator();
			int i = 0;
			while (it.hasNext()) {
				i += 1;
				listaOut.add(parsearUnaFila(tagDia, (JSONObject) it.next()));
			}

		} catch (ParseException e) {

			e.printStackTrace();
		}

		String out = "";

		if (!listaOut.isEmpty()) {
			int i = 0;
			for (String cadena : listaOut) {
				i += 1;
				out += cadena;

				// fin de linea (salvo ultima linea)
				if (i < listaOut.size()) {
					out += Constantes.SEPARADOR_FILA;
				}
			}
		}

		return out;
	}
	
	/**
	 * @param fila
	 * @return
	 */
	public String parsearUnaFila(String tagDia, JSONObject fila) {

		StringBuffer bufferParaAcumular = new StringBuffer();

		bufferParaAcumular.append(tagDia + Constantes.SEPARADOR_CAMPO);

		bufferParaAcumular.append((String) fila.get("ticker") + Constantes.SEPARADOR_CAMPO);// ticker
		bufferParaAcumular.append((String) fila.get("is_active") + Constantes.SEPARADOR_CAMPO);// activo
		bufferParaAcumular.append((String) fila.get("is_supported_exchange") + Constantes.SEPARADOR_CAMPO);// permiteOperar
		bufferParaAcumular.append((String) fila.get("id") + Constantes.SEPARADOR_CAMPO);// id
		bufferParaAcumular.append((String) fila.get("title") + Constantes.SEPARADOR_CAMPO);// title

		JSONArray columnas = (JSONArray) fila.get("columns");

		Map<String, String> mapa = aplanar(columnas);

		// TODO Me fio de que el orden de las columnas no va a cambiar
		int i = 0;
		for (String clave : mapa.keySet()) {

			i += 1;

			bufferParaAcumular.append(mapa.get(clave));
			if (i < mapa.size()) {
				bufferParaAcumular.append(Constantes.SEPARADOR_CAMPO);
			}


		}

		return bufferParaAcumular.toString();
	}

	/**
	 * @param columnas
	 * @return
	 */
	public Map<String, String> aplanar(JSONArray columnas) {
		Map<String, String> mapa = new HashMap<String, String>();
		Iterator it = columnas.iterator();
		while (it.hasNext()) {
			JSONObject columna = (JSONObject) it.next();
			mapa.put((String) columna.get("field"), (String) columna.get("value"));
		}
		return mapa;
	}

}
