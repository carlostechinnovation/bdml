package casa.galgos.gbgb;

import java.util.Calendar;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class GbgbParserCarreraDetalleTest {

	static Long idCarrera = 2030316L;
	static Long idCampeonato = 151752L;

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "galgos_20171021_GBGB_bruto_carrera_2030316");

	@Test
	public void testParsear() throws Exception {

		GbgbCarrera out = GbgbParserCarreraDetalle.parsear(idCarrera, idCampeonato, res.getContent("ISO-8859-1"));

		Assert.assertTrue(out != null);

		Assert.assertTrue(out.id_carrera.equals(idCarrera));
		Assert.assertTrue(out.id_campeonato.equals(idCampeonato));
		Assert.assertTrue(out.track.equals("Central Park"));
		Assert.assertTrue(out.clase.equals("D3"));
		Assert.assertTrue(out.fechayhora.get(Calendar.DAY_OF_MONTH) == 22);
		Assert.assertTrue(out.fechayhora.get(Calendar.MONTH) == 10);
		Assert.assertTrue(out.fechayhora.get(Calendar.YEAR) == 2017);
		Assert.assertTrue(out.fechayhora.get(Calendar.HOUR) == 19);
		Assert.assertTrue(out.fechayhora.get(Calendar.MINUTE) == 54);
		Assert.assertTrue(out.distancia.equals(265));

		// DETALLE
		Assert.assertTrue(out.detalle.premio_primer_puesto.equals(43));
		Assert.assertTrue(out.detalle.premio_otros.equals(30));
		Assert.assertTrue(out.detalle.premio_total_carrera.equals(193));

		Assert.assertTrue(out.detalle.going_allowance.equals(false));
		Assert.assertTrue(out.detalle.fc_1.equals("2"));
		Assert.assertTrue(out.detalle.fc_2.equals("1"));
		Assert.assertTrue(out.detalle.fc_pounds.equals("11.75"));
		Assert.assertTrue(out.detalle.tc_1.equals("2"));
		Assert.assertTrue(out.detalle.tc_2.equals("1"));
		Assert.assertTrue(out.detalle.tc_3.equals("3"));
		Assert.assertTrue(out.detalle.tc_pounds.equals("23.19"));

		Assert.assertTrue(out.detalle.puesto6.equals("Dunham Tiffany#6#9/2# #17.22 (HD)#28.4#R J Holloway####Wide"));

	}

	@Test
	public void testEspecialParsear() throws Exception {

		String c = "(Season: Unknown) bk b Vans Escalade - Quam Chrisse Jul-2015 ( Weight: 25.0 )";

		String[] partes = c.replace(")", "XXXDIVISORXXX").split("XXXDIVISORXXX");
		String season = "";
		String abcd = "";
		if (partes.length == 1) {
			abcd = partes[0];
		} else if (partes.length == 2) {
			season = partes[0].split("eason")[1].trim();
			abcd = partes[1];
		}

		String abc = abcd.split("Weight")[0].replace("(", "");
		String galgo_padre = "";
		String galgo_madre = "";
		String nacimiento = "";

		String peso_galgo = abcd.split("Weight")[1].replace(")", "").replace(":", "").trim();
		Assert.assertTrue(peso_galgo.equals("25.0"));

	}

}