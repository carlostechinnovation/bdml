package casa.galgos;

import java.io.IOException;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;

public class GalgosManagerTest {

	String param2 = "20171021";

	@Before
	public void iniciar() {
	}

	// TODO @Test
	public void descargarYparsearCarrerasDeGalgosTest() throws Exception {

		String param3 = "/galgos_20171021_GBGB_bruto";

		GalgosManager.getInstancia().descargarYparsearCarrerasDeGalgos(param2, param3);

		Assert.assertTrue(GalgosManager.getInstancia().idCarrerasCampeonatoPendientes != null);

		// 0 carreras pendientes
		Assert.assertTrue(GalgosManager.getInstancia().idCarrerasCampeonatoPendientes.size() == 0);

	}

	@Test
	public void descargarCarrerasSinFiltrarPorDiaTest() throws IOException {

		String param3 = "/galgos_20171021_GBGB_bruto";
		GalgosManager.getInstancia().descargarCarrerasSinFiltrarPorDia(param2, param3);

		int x = 0;

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
		GalgosManager.getInstancia().descargarTodosLosHistoricos(param3);

		int x = 0;

	}

}
