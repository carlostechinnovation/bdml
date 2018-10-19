package casa.galgos.weather;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;

/**
 * @author root
 *
 */
public class AccuweatherDiaParseadoTest {

	AccuweatherDiaParseado modelo = new AccuweatherDiaParseado();

	@Before
	public void iniciar() {
		llenar();
	}

	private void llenar() {
		modelo.anio = 2018;
		modelo.mes = 10;
		modelo.dia = 15;
		modelo.real = true;
		modelo.tempMin = 5;
		modelo.tempMax = 15;
		modelo.historicAvgMin = 7;
		modelo.historicAvgMax = 11;
		modelo.texto = "very cloudy and some wind";
		modelo.rain = false;
		modelo.wind = true;
		modelo.cloud = true;
		modelo.sun = false;
		modelo.snow = false;
	}

	@Test
	public void generarInsertorUpdateTest() throws Exception {
		String out = modelo.generarInsertorUpdate("mi_estadio");
		Assert.assertTrue(out.contains("mi_estadio"));
		System.out.println(out);
	}

	@After
	public void terminar() {
	}

}