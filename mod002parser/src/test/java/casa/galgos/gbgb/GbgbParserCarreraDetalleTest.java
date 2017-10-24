package casa.galgos.gbgb;

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

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "galgos_20171021_GBGB_bruto_carrera_2030316");

	@Test
	public void testParsear() throws Exception {

		GbgbCarreraDetalle out = GbgbParserCarreraDetalle.parsear(res.getContent("ISO-8859-1"));

		Assert.assertTrue(out != null);
		Assert.assertTrue(out.premio_primer_puesto.equals(43));
		Assert.assertTrue(out.premio_otros.equals(30));
		Assert.assertTrue(out.premio_total_carrera.equals(193));

		Assert.assertTrue(out.going_allowance.equals(false));
		Assert.assertTrue(out.fc_1.equals("2"));
		Assert.assertTrue(out.fc_2.equals("1"));
		Assert.assertTrue(out.fc_pounds.equals("11.75"));
		Assert.assertTrue(out.tc_1.equals("2"));
		Assert.assertTrue(out.tc_2.equals("1"));
		Assert.assertTrue(out.tc_3.equals("3"));
		Assert.assertTrue(out.tc_pounds.equals("23.19"));

		Assert.assertTrue(out.puesto6.equals("Dunham Tiffany#6#9/2# #17.22 (HD)#28.4#R J Holloway####Wide"));

	}

	@Test
	public void testEspecialParsear() throws Exception {
		String a = "bk d Sparta Maestro - Buds Of May Sep-2015 ( Weight: 30.7 )";

		String peso_galgo = a.split("Weight")[1].replace(")", "").replace(":", "").trim();
		String galgo_padre = "";
		String galgo_madre = "";
		String nacimiento = "";

		Assert.assertTrue(peso_galgo.equals("30.7"));
		// TODO Rellenar
	}

}