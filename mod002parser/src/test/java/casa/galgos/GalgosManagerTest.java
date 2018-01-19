package casa.galgos;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import casa.galgos.gbgb.GbgbGalgoHistoricoCarrera;
import casa.galgos.gbgb.GbgbParserGalgoHistorico;
import junit.framework.Assert;
import utilidades.Constantes;

public class GalgosManagerTest {

	@Before
	public void iniciar() {
	}

	@Test
	public void cargarUrlsHistoricosDeGalgosInicialesTest() {

		String param3 = "/root/git/bdml/mod002parser/src/test/resources/galgos_iniciales.txt";

		GalgosManager gm = GalgosManager.getInstancia();
		gm.cargarUrlsHistoricosDeGalgosIniciales(param3);

		Assert.assertTrue(gm.urlsHistoricoGalgos.size() == 6);

	}

	// TODO @Test
	public void descargarYProcesarCarreraYAcumularUrlsHistoricosTest() throws IOException {

		String param3 = "/galgos_20171021_GBGB_bruto";

		GalgosManager.getInstancia().descargarYProcesarCarreraYAcumularUrlsHistoricos(2030316L, 151752L, param3);

		int x = 0;
	}

	// TODO @Test
	public void descargarTodosLosHistoricosTest() throws IOException {
		String param3 = "/galgos_20171021_GBGB_bruto";
		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();
		Integer prof = 1;
		GalgosManager.getInstancia().descargarTodosLosHistoricos(param3, gpgh, prof);

		int x = 0;

	}

	@Test
	public void minimoTest() {
		List<Integer> lista = new ArrayList<Integer>();
		lista.add(1);
		lista.add(2);
		lista.add(3);
		Assert.assertTrue(Collections.min(lista).equals(1));
	}

	@Test
	public void extraerSiguienteCarreraPendienteTest() {

		GalgosManager gm = GalgosManager.getInstancia();

		rellenarCarrerasPendientes(gm, 1);
		rellenarCarrerasPendientes(gm, 2);

		Assert.assertTrue(gm.extraerSiguienteCarreraPendiente().equals("11"));

	}

	private void rellenarCarrerasPendientes(GalgosManager gm, Integer prof) {

		List<String> cp = new ArrayList<String>();
		cp.add(String.valueOf(prof) + "1");
		cp.add(String.valueOf(prof) + "2");
		cp.add(String.valueOf(prof) + "3");
		ProfundidadCarreras p = new ProfundidadCarreras(prof, cp);
		gm.profCarrerasPendientes.add(p);
	}

	@Test
	public void isHistoricoInsertableTest() {

		GalgosManager instancia = GalgosManager.getInstancia();
		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.set(Calendar.YEAR, 2015);

		Calendar fechaFutura = Calendar.getInstance();
		fechaFutura.set(Calendar.YEAR, 2050);
		GbgbGalgoHistoricoCarrera filaFutura = new GbgbGalgoHistoricoCarrera(101L, 201L, fechaFutura, null, null, null,
				null, null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outFutura = instancia.isHistoricoInsertable(filaFutura, fechaUmbralAnterior);
		Assert.assertTrue(outFutura == false);

		Calendar fechaBien = Calendar.getInstance();
		fechaBien.set(Calendar.YEAR, 2017);
		GbgbGalgoHistoricoCarrera filaBien = new GbgbGalgoHistoricoCarrera(102L, 202L, fechaBien, null, null, null, "6",
				null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outBien = instancia.isHistoricoInsertable(filaBien, fechaUmbralAnterior);
		Assert.assertTrue(outBien);

		Calendar fechaMuyAntigua = Calendar.getInstance();
		fechaMuyAntigua.set(Calendar.YEAR, 2010);
		GbgbGalgoHistoricoCarrera filaMuyAntigua = new GbgbGalgoHistoricoCarrera(103L, 203L, fechaMuyAntigua, null,
				null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outMuyAntigua = instancia.isHistoricoInsertable(filaMuyAntigua, fechaUmbralAnterior);
		Assert.assertTrue(outMuyAntigua == false);
	}

	@Test
	public void getFechaUmbralAnteriorTest() {

		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.add(Calendar.DAY_OF_MONTH, -1 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
		System.out.println("-->fechaUmbralAnterior = " + sdf.format(fechaUmbralAnterior.getTime()));

		Long a = Calendar.getInstance().getTimeInMillis();
		Long b = fechaUmbralAnterior.getTimeInMillis();
		Long diferenciaObtenida = a - b;
		Long diferenciaEsperada = Long
				.valueOf(-1000 * 60 * 60 * 24 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		// Assert.assertTrue(diferenciaObtenida.equals(diferenciaEsperada));

		Calendar out = GalgosManager.getFechaUmbralAnterior();

		// Assert.assertTrue((Calendar.getInstance().getTimeInMillis() -
		// out.getTimeInMillis()) == (1000 * 60 * 60 * 24
		// * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES));

	}

	// TODO @Test
	public void calcularVelocidadRealMedianaRecienteTest() {

	}

	// TODO @Test
	public void calcularVelocidadConGoingMedianaRecienteTest() {

	}

	@Test
	public void mostrarRemarksSinTraducirTest() {

		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();

		gpgh.remarksClavesSinTraduccion.put("claveA", 3);
		gpgh.remarksClavesSinTraduccion.put("claveB", 7);

		String out = GalgosManager.mostrarRemarksSinTraducir(gpgh);

		Assert.assertTrue(out.equals("3|claveA\\n7|claveB\\n"));
	}

	@Test
	public void escapeEspaciosUrlTest() {

		String cadena1 = "hola carlos";
		String cadena2 = "hola%20carlos";

		Assert.assertEquals(cadena1, cadena2.replaceAll("%20", " "));

	}

}
