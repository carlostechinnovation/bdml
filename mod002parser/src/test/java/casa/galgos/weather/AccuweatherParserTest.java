package casa.galgos.weather;

import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class AccuweatherParserTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile webPasadoypresente = new ResourceFile("/" + "2018_10_Belle Vue.html");

	@Rule
	public ResourceFile webFuturo = new ResourceFile("/" + "2019_1_Belle Vue.html");

	@Test
	public void parsearWebsTest() throws Exception {
		nucleo(webPasadoypresente, 12, (31 - 12), true);
		nucleo(webFuturo, 0, 31, false);
	}

	/**
	 * @param pagina
	 */
	public void nucleo(ResourceFile pagina, int numEsperadosPasados, int numEsperadosPresenteYFuturos,
			boolean problemaYesterday) throws Exception {

		String contenidoWebBruta = pagina.getContent("ISO-8859-1");

		AccuweatherParseado out = AccuweatherParser.parsear(contenidoWebBruta, pagina.getFile().getAbsolutePath());

		Assert.assertTrue(out != null);
		Assert.assertTrue(out.diasParseados.size() > 0);

		int contPasados = 0, contPresenteYFuturos = 0;
		for (AccuweatherDiaParseado adp : out.diasParseados) {
			Assert.assertTrue(adp.minimoRelleno());

			if (adp.real) {
				contPasados++;
			} else {
				contPresenteYFuturos++;
			}
		}

		if (problemaYesterday) {
			// TODO Al ejecutar Yesterday, lo sacamos del momento de ejecucion de Java.
			// Damos por hecho que acabamos de descargar los datos brutos y los estamos
			// parseando de seguido
			numEsperadosPasados--;
		}

		Assert.assertTrue(contPasados == numEsperadosPasados);
		Assert.assertTrue(contPresenteYFuturos == numEsperadosPresenteYFuturos);

	}

	@Test
	public void generarInsertorUpdateSinTextoTest() throws Exception {
		AccuweatherDiaParseado in = new AccuweatherDiaParseado();

		in.anio = 2018;
		in.mes = 10;
		in.dia = 15;
		in.real = false;
		in.tempMin = 5;
		in.tempMax = 15;
		in.historicAvgMin = 6;
		in.historicAvgMax = 8;
		in.texto = null;
		in.rain = false;
		in.wind = false;
		in.cloud = false;
		in.sun = false;
		in.snow = false;

		String out = in.generarInsertorUpdate("mi_estadio");

		System.out.println(out);
	}

	@Test
	public void generarInsertorUpdateConTextoTest() throws Exception {
		AccuweatherDiaParseado in = new AccuweatherDiaParseado();

		in.anio = 2018;
		in.mes = 10;
		in.dia = 15;
		in.real = false;
		in.tempMin = 5;
		in.tempMax = 15;
		in.historicAvgMin = 6;
		in.historicAvgMax = 8;
		in.texto = null;
		in.rain = false;
		in.wind = false;
		in.cloud = false;
		in.sun = false;
		in.snow = false;

		String out = in.generarInsertorUpdate("mi_estadio");

		System.out.println(out);

	}

	@After
	public void terminar() {
	}

}